#!/bin/bash

# Default values
LogDir="/var/logs"
DaysToKeepLogs=7
DaysToKeepBackups=30

# Function to prompt for input when parameter is missing
prompt_for_input() {
    local message="$1"
    local default="$2"

    if [[ -z "$default" ]]; then
        read -rp "$message: " default
    fi
    echo "$default"
}

# Assign passed parameters or prompt if missing
LogDir="${1:-$(prompt_for_input 'Enter the log directory' "$LogDir")}"
DaysToKeepLogs="${2:-$(prompt_for_input 'How many days of logs do you want to keep?' "$DaysToKeepLogs")}"
DaysToKeepBackups="${3:-$(prompt_for_input 'How many days of backup archives do you want to keep?' "$DaysToKeepBackups")}"

echo "Log Directory: $LogDir"
echo "Days to keep logs: $DaysToKeepLogs"
echo "Days to keep backups: $DaysToKeepBackups"

# Validate log directory
if [[ ! -d "$LogDir" ]]; then
    echo "Error: Log directory does not exist." >&2
    exit 1
fi

# Archive directory
ArchiveDir="$LogDir/Archive"
mkdir -p "$ArchiveDir"

# Archive file name
Timestamp=$(date +"%Y%m%d_%H%M%S")
ArchiveFile="$ArchiveDir/logs_archive_$Timestamp.tar.gz"

# Find and archive old log and txt files
find "$LogDir" -type f \( -name "*.log" -o -name "*.txt" \) -mtime +"$DaysToKeepLogs" -print0 | tar -czvf "$ArchiveFile" --null -T - 2>/dev/null

if [[ -s "$ArchiveFile" ]]; then
    echo "Logs archived in $ArchiveFile on $(date)" >> "$ArchiveDir/archive_log.txt"
    echo "Archiving completed: $ArchiveFile"
else
    echo "No .log or .txt files found to archive."
    rm -f "$ArchiveFile" # Remove empty archive
fi

# Delete logs older than specified days
find "$LogDir" -type f \( -name "*.log" -o -name "*.txt" \) -mtime +"$DaysToKeepLogs" -delete
echo "Old logs deleted."

# Delete backup archives older than specified days
find "$ArchiveDir" -type f -name "*.tar.gz" -mtime +"$DaysToKeepBackups" -delete
echo "Backup archives older than $DaysToKeepBackups days have been deleted."

# Schedule execution with cron
read -rp "Do you want to schedule this script to run daily at 2:00 AM? (y/n): " Confirm

if [[ "$Confirm" == "y" ]]; then
    script_path="$(realpath "$0")"
    cron_job="0 2 * * * $script_path $LogDir $DaysToKeepLogs $DaysToKeepBackups"
    
    # Check if cron job exists
    if crontab -l | grep -Fq "$script_path"; then
        echo "A scheduled task for this script already exists."
    else
        (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
        echo "Scheduled task added to cron."
    fi
else
    echo "Scheduled task not added."
fi
