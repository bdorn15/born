#!/bin/bash

# Script to monitor system and display information on all terminals

# Gather system architecture and kernel version
architecture=$(uname -m)
kernel_version=$(uname -r)

# Gather the number of physical processors
num_processors=$(nproc --all)

# Gather the number of virtual processors
num_virtual_processors=$(lscpu | grep '^CPU(s):' | awk '{print $2}')

# Gather available RAM and RAM utilization
ram_total=$(free -h | grep Mem | awk '{print $2}')
ram_used=$(free -h | grep Mem | awk '{print $3}')
ram_percentage=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | bc)

# Gather available storage and disk usage percentage
storage_total=$(df -h / | grep / | awk '{print $2}')
storage_used=$(df -h / | grep / | awk '{print $3}')
storage_percentage=$(df / | grep / | awk '{print $5}')

# Gather CPU usage (average)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')

# Last reboot time
last_reboot=$(who -b | awk '{print $3, $4}')

# Check if LVM is active
lvm_status=$(lsblk | grep lvm)

# Number of active connections
active_connections=$(ss -tuln | wc -l)

# Number of users logged in
logged_in_users=$(who | wc -l)

# Get the IPv4 address and MAC address
ipv4_address=$(hostname -I | awk '{print $1}')
mac_address=$(ip link show | grep "ether" | awk '{print $2}')

# Number of commands executed with sudo
sudo_usage=$(journalctl _COMM=sudo | wc -l)

# Display the gathered information using `wall`
wall <<EOF
System Information:
-------------------
- Architecture: $architecture
- Kernel Version: $kernel_version
- Physical Processors: $num_processors
- Virtual Processors: $num_virtual_processors
- RAM: $ram_used/$ram_total ($ram_percentage% used)
- Storage: $storage_used/$storage_total ($storage_percentage used)
- CPU Usage: $cpu_usage
- Last Reboot: $last_reboot
- LVM Active: ${lvm_status:+Yes} ${lvm_status:-No}
- Active Connections: $active_connections
- Logged-in Users: $logged_in_users
- IPv4 Address: $ipv4_address
- MAC Address: $mac_address
- Commands Executed with Sudo: $sudo_usage
EOF

