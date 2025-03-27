#!/bin/bash

param (
    [string]$LogDir = "C:\Logs",
    [int]$DaysToKeepLogs = 7,
    [int]$DaysToKeepBackups = 30
)

Write-Host "Log Directory: $LogDir"
Write-Host "Days to keep logs: $DaysToKeepLogs"
Write-Host "Days to keep backups: $DaysToKeepBackups"

# Function to prompt user for input with default value
function Prompt-ForInput {
    param (
        [string]$Message,
        [string]$Default
    )
    if (-not $Default -or $Default -eq "") {
        return Read-Host "$Message"
    }
    return $Default
}

# Interactive user input
$LogDir = Prompt-ForInput "Enter the log directory" $LogDir
$DaysToKeepLogs = [int](Prompt-ForInput "How many days of logs do you want to keep?" $DaysToKeepLogs)
$DaysToKeepBackups = [int](Prompt-ForInput "How many days of backup archives do you want to keep?" $DaysToKeepBackups)

# Validate log directory
if (-Not (Test-Path $LogDir -PathType Container)) {
    Write-Host "Error: Log directory does not exist." -ForegroundColor Red
    exit 1
}

# Archive directory
$ArchiveDir = "$LogDir\Archive"
if (-Not (Test-Path $ArchiveDir)) { New-Item -ItemType Directory -Path $ArchiveDir | Out-Null }

# Archive file name
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ArchiveFile = "$ArchiveDir\logs_archive_$Timestamp.zip"

# Get log and txt files older than specified days
$FilesToArchive = Get-ChildItem -Path $LogDir -File | 
    Where-Object { ($_.Extension -match "\.(log|txt)$") -and ($_.LastWriteTime -lt (Get-Date).AddDays(-$DaysToKeepLogs)) }

# Check if there are files to archive
if ($FilesToArchive.Count -gt 0) {
    $FilesToArchive | Compress-Archive -DestinationPath $ArchiveFile -Force
    "Logs archived in $ArchiveFile on $(Get-Date)" | Out-File -Append "$ArchiveDir\archive_log.txt"
    Write-Host "Archiving completed: $ArchiveFile" -ForegroundColor Green
} else {
    Write-Host "No .log or .txt files found to archive." -ForegroundColor Yellow
}

# Delete logs older than specified days
Get-ChildItem -Path $LogDir -File | Where-Object { ($_.Extension -match "\.(log|txt)$") -and ($_.LastWriteTime -lt (Get-Date).AddDays(-$DaysToKeepLogs)) } | Remove-Item -Force

Write-Host "Old logs deleted." -ForegroundColor Green

# Delete backup archives older than specified days
Get-ChildItem -Path $ArchiveDir -File -Filter "*.zip" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$DaysToKeepBackups) } | Remove-Item -Force

Write-Host "Backup archives older than $DaysToKeepBackups days have been deleted." -ForegroundColor Green

# Setup scheduled task function
$scriptPath = "$PSScriptRoot\log-archive-tool.ps1"
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$scriptPath`" -LogDir `"$LogPath`" -DaysToKeepLogs $KeepDays -DaysToKeepBackups $BackupDays"
$Trigger = New-ScheduledTaskTrigger -Daily -At 2:00AM
$Settings = New-ScheduledTaskSettingsSet 

$Confirm = Read-Host "Do you want to schedule this script to run daily at 2:00 AM? (y/n)"

if ($Confirm -eq "y") {
    $TaskName = Read-Host "Schedule name"

    # Check if the task already exists
    $ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    if ($ExistingTask) {
        Write-Host "A scheduled task with the name '$TaskName' already exists." -ForegroundColor Red
        exit 1
    }
    Register-ScheduledTask -TaskName `"$TaskName`" -Action $Action -Trigger $Trigger -Settings $Settings -User "SYSTEM" -RunLevel Highest
    Write-Host "Scheduled task added: $TaskName" -ForegroundColor Cyan
} else {
    Write-Host "Scheduled task not added." -ForegroundColor Yellow
}
