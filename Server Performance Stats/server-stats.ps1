Write-Host "######################"
Write-Host "# Server Performance Stats #"
Write-Host "######################"

# OS Version
Write-Host "`nOS Version:"
(Get-CimInstance Win32_OperatingSystem).Caption

# Uptime
Write-Host "`nSystem Uptime:"
$uptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$uptimeFormatted = [math]::Round((New-TimeSpan -Start $uptime).TotalHours, 2)
Write-Host "Uptime: $uptimeFormatted hours"

# CPU Usage
Write-Host "`n###################"
Write-Host "# Total CPU Usage #"
Write-Host "###################"
Get-WmiObject Win32_Processor | Select-Object -ExpandProperty LoadPercentage | ForEach-Object { "Usage: $_%" }

# Memory Usage
Write-Host "`n######################"
Write-Host "# Total Memory Usage #"
Write-Host "######################"
Get-CimInstance Win32_OperatingSystem | ForEach-Object {
    $total = $_.TotalVisibleMemorySize / 1MB
    $free = $_.FreePhysicalMemory / 1MB
    $used = $total - $free
    $percentUsed = ($used / $total) * 100
    $percentFree = ($free / $total) * 100
    "Total: {0:N1}Gi" -f $total
    "Used: {0:N1}Gi ({1:N2}%)" -f $used, $percentUsed
    "Free: {0:N1}Gi ({1:N2}%)" -f $free, $percentFree
}

# Disk Usage
Write-Host "`n####################"
Write-Host "# Total Disk Usage #"
Write-Host "####################"
Get-PSDrive C | ForEach-Object {
    $total = $_.Used + $_.Free
    $used = $_.Used
    $free = $_.Free
    $percentUsed = ($used / $total) * 100
    $percentFree = ($free / $total) * 100
    "Total: {0:N1}G" -f ($total / 1GB)
    "Used: {0:N1}G ({1:N2}%)" -f ($used / 1GB), $percentUsed
    "Free: {0:N1}G ({1:N2}%)" -f ($free / 1GB), $percentFree
}

# Top 5 Processes by Memory
Write-Host "`n###################################"
Write-Host "# Top 5 Processes by Memory Usage #"
Write-Host "###################################"
Get-Process | Sort-Object -Descending WS | Select-Object -First 5 | Format-Table -AutoSize ProcessName,Id,WS

# Top 5 Processes by CPU
Write-Host "`n################################"
Write-Host "# Top 5 Processes by CPU Usage #"
Write-Host "################################"
Get-Process | Sort-Object -Descending CPU | Select-Object -First 5 | Format-Table -AutoSize ProcessName,Id,CPU

# Logged-in Users
Write-Host "`n#######################"
Write-Host "# Logged-in Users #"
Write-Host "#######################"
query user

# Failed Login Attempts (Stretch Goal)
Write-Host "`n#########################"
Write-Host "# Failed Login Attempts #"
Write-Host "#########################"
(Get-EventLog Security -Newest 50 -InstanceId 4625 -ErrorAction SilentlyContinue).Count
