#!/bin/bash

echo "######################"
echo "# Server Performance Stats #"
echo "######################"

# OS Version
echo -e "\nOS Version:"
cat /etc/os-release | grep -E "PRETTY_NAME" | cut -d= -f2 | tr -d '"'

# Uptime
echo -e "\nSystem Uptime:"
uptime -p

# CPU Usage
echo -e "\n###################"
echo "# Total CPU Usage #"
echo "###################"
top -bn1 | grep "Cpu(s)" | awk '{print "Usage: " 100 - $8 "%"}'

# Memory Usage
echo -e "\n######################"
echo "# Total Memory Usage #"
echo "######################"
free -h | awk '/Mem:/ {print "Total: " $2 "\nUsed: " $3 " (" $3/$2*100 "%)\nFree: " $4 " (" $4/$2*100 "%)"}'

# Disk Usage
echo -e "\n####################"
echo "# Total Disk Usage #"
echo "####################"
df -h --output=source,size,used,avail,pcent | grep "^/dev"

# Top 5 Processes by Memory
echo -e "\n###################################"
echo "# Top 5 Processes by Memory Usage #"
echo "###################################"
ps aux --sort=-%mem | awk 'NR<=6 {print $1, $2, $4, $11}'

# Top 5 Processes by CPU
echo -e "\n################################"
echo "# Top 5 Processes by CPU Usage #"
echo "################################"
ps aux --sort=-%cpu | awk 'NR<=6 {print $1, $2, $3, $11}'

# Logged-in Users
echo -e "\n#######################"
echo "# Logged-in Users #"
echo "#######################"
who

# Failed Login Attempts (Stretch Goal)
echo -e "\n#########################"
echo "# Failed Login Attempts #"
echo "#########################"
journalctl _SYSTEMD_UNIT=ssh.service | grep "Failed password" | wc -l
