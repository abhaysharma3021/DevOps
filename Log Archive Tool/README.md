# Log Archive Tool

## Overview

This Log Archive Tool helps in archiving and cleaning up log files. It supports both Linux and Windows platforms using shell scripts and PowerShell scripts. The tool compresses log files older than a specified number of days and removes backups that exceed a defined retention period.

## Features

- Archives log files older than a given number of days
- Removes backups older than a set retention period
- Can be scheduled to run automatically using cron (Linux) or Task Scheduler (Windows)
- Supports both Bash (.sh) and PowerShell (.ps1) scripts

## Prerequisites

### Linux

- A Unix-based system with Bash installed
- `tar` and `gzip` should be available on the system
- Cron should be installed for scheduling

### Windows

- Windows PowerShell (for `.ps1` script execution) Run as Administrator
- Git Bash, WSL (Windows Subsystem for Linux), or Cygwin (for `.sh` script execution)
- Task Scheduler (for automation)

## Installation

### Linux Installation

1. Download the script:
   ```sh
   wget https://raw.githubusercontent.com/abhaysharma3021/DevOps/main/Log%20Archive%20Tool/log-archive-tool.sh -O log-archive-tool.sh
   ```
2. Grant execute permissions to the script:
   ```sh
   chmod +x log-archive-tool.sh
   ```
3. (Optional) Install `cron` if not installed:
   ```sh
   sudo apt-get install cron  # Debian/Ubuntu
   sudo yum install cronie    # CentOS/RHEL
   ```

### Windows Installation

#### Using PowerShell

1. Download the script:
   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/abhaysharma3021/DevOps/main/Log%20Archive%20Tool/log-archive-tool.ps1" -OutFile "log-archive-tool.ps1"
   ```
2. Allow script execution if not enabled:
   ```powershell
   Set-ExecutionPolicy Unrestricted -Scope Process
   ```
3. Run the script:
   ```powershell
   .\log-archive-tool.ps1 -LogDir "C:\path\to\logs" -DaysToKeepLogs 7 -DaysToKeepBackups 30
   ```

#### Using Git Bash/WSL

1. Install Git Bash, WSL, or Cygwin if not already installed.
2. Download the script:
   ```sh
   wget https://raw.githubusercontent.com/abhaysharma3021/DevOps/main/Log%20Archive%20Tool/log-archive-tool.sh -O log-archive-tool.sh
   ```
3. Run the script using Git Bash or WSL:
   ```sh
   bash log-archive-tool.sh "C:/path/to/logs" 7 30
   ```

## Usage

### Linux (Bash Script)

Run the script manually with:

```sh
bash log-archive-tool.sh "/path/to/logs" <days_to_keep_logs> <days_to_keep_backups>
```

Example:

```sh
bash log-archive-tool.sh "/var/logs" 7 30
```

This archives logs older than 7 days and deletes backups older than 30 days.

### Windows (PowerShell Script)

Run the script manually with:

```powershell
.\log-archive-tool.ps1 -LogPath "C:\path\to\logs" -DaysToKeep 7 -BackupDays 30
```

Example:

```powershell
.\log-archive-tool.ps1 -LogPath "C:\Logs" -DaysToKeep 7 -BackupDays 30
```

## Scheduling the Script

### Linux (Cron Job)

To schedule the script to run daily at 2:00 AM:

```sh
echo "0 2 * * * /bin/bash /path/to/log-archive-tool.sh \"/var/logs\" 7 30" | crontab -
```

Verify scheduled tasks:

```sh
crontab -l
```

### Windows (Task Scheduler)

1. Open **Task Scheduler** and create a new task.
2. Set the **trigger** to run daily at a specific time.
3. Set the **action** to run PowerShell with the following command:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\log-archive-tool.ps1" -LogPath "C:\Logs" -DaysToKeep 7 -BackupDays 30
   ```

## Troubleshooting

- **Permission denied:** Run `chmod +x log-archive-tool.sh` and try again.
- **Command not found:** Ensure Bash, `tar`, and `gzip` are installed.
- **Cron job not running (Linux):** Check the crontab with `crontab -l` and ensure the cron service is running (`sudo service cron start`).
- **PowerShell execution policy restricted (Windows):** Run `Set-ExecutionPolicy Unrestricted -Scope Process` before executing the script.
- **Task Scheduler not running (Windows):** Verify the task is enabled and running under the correct user account.

## License

This project is licensed under the MIT License.
