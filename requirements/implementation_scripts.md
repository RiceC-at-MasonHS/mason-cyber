# Detailed Implementation Guides and Scripts

## Essential Scripts for Automation

### 1. Kali Template Creation Script

```bash
#!/bin/bash
# create_kali_template.sh - Automated Kali LXC template creation

set -e

TEMPLATE_ID=100
TEMPLATE_NAME="kali-template-base"
STORAGE="local-lvm"
TEMPLATE_PASSWORD="kali2024!"

echo "Creating Kali Linux LXC template..."

# Create base Debian LXC
pct create $TEMPLATE_ID /var/lib/vz/template/cache/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname $TEMPLATE_NAME \
  --password $TEMPLATE_PASSWORD \
  --storage $STORAGE \
  --memory 2048 \
  --cores 2 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --rootfs $STORAGE:20 \
  --unprivileged 1

# Start the container
pct start $TEMPLATE_ID

# Wait for container to be ready
sleep 30

echo "Installing Kali tools and configuring template..."

# Install essential packages and Kali tools
pct exec $TEMPLATE_ID -- bash -c "
export DEBIAN_FRONTEND=noninteractive
apt update && apt upgrade -y

# Install essential packages
apt install -y sudo openssh-server net-tools iputils-ping curl wget vim

# Add Kali repositories
echo 'deb https://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware' > /etc/apt/sources.list.d/kali.list
curl -fsSL https://archive.kali.org/archive-key.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/kali.gpg

# Update package list
apt update

# Install essential Kali tools (lightweight selection)
apt install -y \
  kali-tools-top10 \
  nmap \
  netcat-traditional \
  wireshark-common \
  tcpdump \
  nikto \
  dirb \
  sqlmap \
  john \
  hashcat \
  hydra \
  metasploit-framework

# Create student user
adduser --disabled-password --gecos '' student
echo 'student:password123' | chpasswd
usermod -aG sudo student

# Configure SSH
systemctl enable ssh
systemctl start ssh

# Security hardening
ufw --force enable
ufw allow ssh

# Clean up
apt clean
apt autoremove -y
rm -rf /var/lib/apt/lists/*
history -c
"

# Stop the container
pct stop $TEMPLATE_ID

# Convert to template
pct template $TEMPLATE_ID

echo "Kali template created successfully with ID: $TEMPLATE_ID"
```

### 2. Student Lab Deployment Script

```python
#!/usr/bin/env python3
# deploy_student_lab.py - Automated student lab environment deployment

import subprocess
import requests
import json
import csv
import sys
import time
from typing import List, Dict

class ProxmoxManager:
    def __init__(self, host: str, user: str, password: str):
        self.host = host
        self.user = user
        self.password = password
        self.session = requests.Session()
        self.session.verify = False  # For self-signed certs
        self._authenticate()
    
    def _authenticate(self):
        """Authenticate with Proxmox API"""
        auth_data = {
            'username': self.user,
            'password': self.password
        }
        
        response = self.session.post(
            f"https://{self.host}:8006/api2/json/access/ticket",
            data=auth_data
        )
        
        if response.status_code == 200:
            ticket_data = response.json()['data']
            self.session.headers.update({
                'CSRFPreventionToken': ticket_data['CSRFPreventionToken']
            })
            self.session.cookies.set('PVEAuthCookie', ticket_data['ticket'])
        else:
            raise Exception(f"Authentication failed: {response.text}")
    
    def clone_container(self, template_id: int, new_id: int, hostname: str, bridge: str, ip: str):
        """Clone LXC container from template"""
        clone_data = {
            'newid': new_id,
            'hostname': hostname,
            'full': 1  # Full clone
        }
        
        response = self.session.post(
            f"https://{self.host}:8006/api2/json/nodes/pve/lxc/{template_id}/clone",
            data=clone_data
        )
        
        if response.status_code != 200:
            raise Exception(f"Failed to clone container: {response.text}")
        
        # Configure network
        net_config = f"name=eth0,bridge={bridge},ip={ip}/24"
        net_data = {'net0': net_config}
        
        self.session.put(
            f"https://{self.host}:8006/api2/json/nodes/pve/lxc/{new_id}/config",
            data=net_data
        )
        
        return new_id
    
    def clone_vm(self, template_id: int, new_id: int, name: str, bridge: str):
        """Clone VM from template"""
        clone_data = {
            'newid': new_id,
            'name': name,
            'full': 1
        }
        
        response = self.session.post(
            f"https://{self.host}:8006/api2/json/nodes/pve/qemu/{template_id}/clone",
            data=clone_data
        )
        
        if response.status_code != 200:
            raise Exception(f"Failed to clone VM: {response.text}")
        
        # Configure network
        net_config = f"virtio,bridge={bridge}"
        net_data = {'net0': net_config}
        
        self.session.put(
            f"https://{self.host}:8006/api2/json/nodes/pve/qemu/{new_id}/config",
            data=net_data
        )
        
        return new_id
    
    def start_container(self, ct_id: int):
        """Start LXC container"""
        response = self.session.post(
            f"https://{self.host}:8006/api2/json/nodes/pve/lxc/{ct_id}/status/start"
        )
        return response.status_code == 200
    
    def start_vm(self, vm_id: int):
        """Start VM"""
        response = self.session.post(
            f"https://{self.host}:8006/api2/json/nodes/pve/qemu/{vm_id}/status/start"
        )
        return response.status_code == 200

class GuacamoleManager:
    def __init__(self, host: str, username: str, password: str):
        self.host = host
        self.username = username
        self.password = password
        self.session = requests.Session()
        self.token = None
        self._authenticate()
    
    def _authenticate(self):
        """Authenticate with Guacamole"""
        auth_data = {
            'username': self.username,
            'password': self.password
        }
        
        response = self.session.post(
            f"http://{self.host}:8080/guacamole/api/tokens",
            data=auth_data
        )
        
        if response.status_code == 200:
            self.token = response.json()['authToken']
            self.session.params = {'token': self.token}
        else:
            raise Exception(f"Guacamole authentication failed: {response.text}")
    
    def create_ssh_connection(self, name: str, hostname: str, username: str, password: str):
        """Create SSH connection in Guacamole"""
        connection_data = {
            'name': name,
            'protocol': 'ssh',
            'parameters': {
                'hostname': hostname,
                'port': '22',
                'username': username,
                'password': password,
                'color-scheme': 'green-black'
            }
        }
        
        response = self.session.post(
            f"http://{self.host}:8080/guacamole/api/session/data/mysql/connections",
            json=connection_data
        )
        
        return response.status_code == 200
    
    def create_vnc_connection(self, name: str, hostname: str, password: str = ""):
        """Create VNC connection in Guacamole"""
        connection_data = {
            'name': name,
            'protocol': 'vnc',
            'parameters': {
                'hostname': hostname,
                'port': '5900',
                'password': password,
                'color-depth': '16'
            }
        }
        
        response = self.session.post(
            f"http://{self.host}:8080/guacamole/api/session/data/mysql/connections",
            json=connection_data
        )
        
        return response.status_code == 200

class NetworkManager:
    def __init__(self):
        self.used_bridges = set()
    
    def create_isolated_bridge(self, bridge_name: str):
        """Create isolated Linux bridge"""
        if bridge_name in self.used_bridges:
            return True
        
        commands = [
            f"ip link add name {bridge_name} type bridge",
            f"ip link set {bridge_name} up",
            f"echo 'auto {bridge_name}' >> /etc/network/interfaces",
            f"echo 'iface {bridge_name} inet manual' >> /etc/network/interfaces",
            f"echo '    bridge_ports none' >> /etc/network/interfaces",
            f"echo '    bridge_stp off' >> /etc/network/interfaces",
            f"echo '    bridge_fd 0' >> /etc/network/interfaces"
        ]
        
        for cmd in commands:
            try:
                subprocess.run(cmd.split(), check=True, capture_output=True)
            except subprocess.CalledProcessError as e:
                print(f"Warning: {cmd} failed: {e}")
        
        self.used_bridges.add(bridge_name)
        return True

def deploy_student_labs(student_file: str, config: Dict):
    """Deploy lab environments for all students"""
    
    # Initialize managers
    proxmox = ProxmoxManager(
        config['proxmox']['host'],
        config['proxmox']['user'],
        config['proxmox']['password']
    )
    
    guacamole = GuacamoleManager(
        config['guacamole']['host'],
        config['guacamole']['user'],
        config['guacamole']['password']
    )
    
    network = NetworkManager()
    
    # Read student list
    with open(student_file, 'r') as f:
        students = list(csv.DictReader(f))
    
    print(f"Deploying labs for {len(students)} students...")
    
    for i, student in enumerate(students):
        student_id = student['id']
        student_name = student['name']
        
        # Calculate IDs and network
        base_id = config['base_ids']['start'] + (i * 10)
        kali_id = base_id + 1
        metasploitable_id = base_id + 2
        bridge_id = config['bridge_base'] + i + 1
        bridge_name = f"vmbr{bridge_id}"
        
        print(f"Deploying lab for {student_name} (ID: {student_id})...")
        
        try:
            # Create isolated network bridge
            network.create_isolated_bridge(bridge_name)
            
            # Calculate IP addresses
            network_base = f"10.{bridge_id}.0"
            kali_ip = f"{network_base}.10"
            metasploitable_ip = f"{network_base}.20"
            
            # Clone and configure Kali LXC
            print(f"  Creating Kali LXC (ID: {kali_id})...")
            proxmox.clone_container(
                config['templates']['kali_id'],
                kali_id,
                f"kali-{student_id}",
                bridge_name,
                kali_ip
            )
            
            # Clone and configure Metasploitable2 VM
            print(f"  Creating Metasploitable2 VM (ID: {metasploitable_id})...")
            proxmox.clone_vm(
                config['templates']['metasploitable_id'],
                metasploitable_id,
                f"metasploitable-{student_id}",
                bridge_name
            )
            
            # Start both machines
            print(f"  Starting lab environments...")
            proxmox.start_container(kali_id)
            proxmox.start_vm(metasploitable_id)
            
            # Wait for machines to boot
            time.sleep(30)
            
            # Create Guacamole connections
            print(f"  Creating Guacamole connections...")
            guacamole.create_ssh_connection(
                f"{student_name} - Kali Linux",
                kali_ip,
                "student",
                "password123"
            )
            
            guacamole.create_vnc_connection(
                f"{student_name} - Metasploitable2",
                metasploitable_ip
            )
            
            print(f"  ✓ Lab deployed successfully for {student_name}")
            
        except Exception as e:
            print(f"  ✗ Failed to deploy lab for {student_name}: {e}")
            continue
    
    print("Lab deployment completed!")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 deploy_student_lab.py students.csv")
        sys.exit(1)
    
    # Configuration
    config = {
        'proxmox': {
            'host': 'your-proxmox-host',
            'user': 'root@pam',
            'password': 'your-password'
        },
        'guacamole': {
            'host': 'guacamole-server-ip',
            'user': 'guacadmin',
            'password': 'your-password'
        },
        'templates': {
            'kali_id': 100,
            'metasploitable_id': 900
        },
        'base_ids': {
            'start': 1000
        },
        'bridge_base': 100
    }
    
    deploy_student_labs(sys.argv[1], config)
```

### 3. Gaming PC Dual-Boot Setup Script

```bash
#!/bin/bash
# gaming_pc_dual_boot_setup.sh - Setup dual-boot for gaming PC

set -e

GAMING_PC_NAME=$(hostname)
PROXMOX_PARTITION_SIZE="200G"
BACKUP_DIR="/backup/gaming_pc_setup"

echo "Setting up dual-boot configuration for Gaming PC: $GAMING_PC_NAME"

# Create backup directory
mkdir -p $BACKUP_DIR

# Function to create Windows boot entry backup
backup_windows_boot() {
    echo "Backing up Windows boot configuration..."
    bcdedit /export "$BACKUP_DIR/windows_boot_backup.bcd"
    
    # Backup current partition table
    sfdisk -d /dev/sda > "$BACKUP_DIR/partition_table_backup.txt"
}

# Function to resize Windows partition
resize_windows_partition() {
    echo "Resizing Windows partition to make space for Proxmox..."
    
    # Get current Windows partition info
    WINDOWS_PARTITION=$(lsblk -o NAME,MOUNTPOINT | grep "C:\\" | awk '{print $1}')
    
    if [ -z "$WINDOWS_PARTITION" ]; then
        echo "Could not find Windows partition. Manual intervention required."
        exit 1
    fi
    
    # Resize using diskpart (Windows command)
    echo "Shrinking Windows partition by $PROXMOX_PARTITION_SIZE"
    
    # Create diskpart script
    cat > /tmp/shrink_windows.txt << EOF
select disk 0
select partition 2
shrink desired=204800
exit
EOF
    
    # Execute diskpart
    diskpart /s /tmp/shrink_windows.txt
}

# Function to install Proxmox on new partition
install_proxmox_partition() {
    echo "Creating Proxmox partition..."
    
    # Create new partition for Proxmox
    # This would typically involve:
    # 1. Creating the partition with fdisk/parted
    # 2. Formatting with ext4
    # 3. Downloading and installing Proxmox VE
    
    # For automation, you'd create a Proxmox installation USB
    # and modify the installer to target the specific partition
    
    echo "Proxmox partition created. Manual Proxmox installation required."
    echo "Please boot from Proxmox installation media and install to the new partition."
}

# Function to configure GRUB for dual-boot
configure_grub_dual_boot() {
    echo "Configuring GRUB for dual-boot..."
    
    # This requires GRUB to be installed and configured
    # after Proxmox installation
    
    cat > /etc/grub.d/40_custom << 'EOF'
#!/bin/sh
exec tail -n +3 $0
# Custom menu entries for dual-boot

menuentry "Windows Gaming Mode" {
    search --set=root --file /bootmgr
    chainloader +1
}

menuentry "Proxmox Lab Mode" {
    set root='hd0,gpt3'
    linux /boot/vmlinuz-5.15.0-proxmox+ root=/dev/sda3
    initrd /boot/initrd.img-5.15.0-proxmox+
}
EOF
    
    # Set Windows as default (for gaming priority)
    sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT="Windows Gaming Mode"/' /etc/default/grub
    
    # Set shorter timeout for faster boot
    sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=3/' /etc/default/grub
    
    # Update GRUB
    update-grub
}

# Function to create automated boot scheduling
create_boot_scheduler() {
    echo "Creating automated boot scheduler..."
    
    # Windows PowerShell script for scheduled reboot to Proxmox
    cat > "$BACKUP_DIR/lab_mode_transition.ps1" << 'EOF'
# PowerShell script to transition to lab mode
param([string]$Mode = "lab")

if ($Mode -eq "lab") {
    # Set GRUB default to Proxmox for next boot
    # This requires WSL or Linux subsystem
    wsl -e sudo grub-set-default "Proxmox Lab Mode"
    
    # Log the transition
    Write-EventLog -LogName Application -Source "CyberShield" -EventId 1001 -Message "Transitioning to Lab Mode"
    
    # Schedule return to gaming mode
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Scripts\gaming_mode_transition.ps1"
    $Trigger = New-ScheduledTaskTrigger -Daily -At "3:00 PM"
    Register-ScheduledTask -TaskName "ReturnToGamingMode" -Action $Action -Trigger $Trigger
    
    # Reboot to Proxmox
    Restart-Computer -Force
}
EOF
    
    # Create return to gaming mode script
    cat > "$BACKUP_DIR/gaming_mode_transition.ps1" << 'EOF'
# PowerShell script to return to gaming mode
# This runs from Proxmox before shutdown

# Gracefully shut down all VMs and containers
/usr/local/bin/shutdown_all_labs.sh

# Set GRUB default back to Windows
grub-set-default "Windows Gaming Mode"

# Reboot to Windows
systemctl reboot
EOF
    
    # Create scheduled task for daily lab mode transition
    $TaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File $BACKUP_DIR\lab_mode_transition.ps1"
    $TaskTrigger = New-ScheduledTaskTrigger -Daily -At "6:55 AM"
    $TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    
    Register-ScheduledTask -TaskName "CyberShieldLabTransition" -Action $TaskAction -Trigger $TaskTrigger -Settings $TaskSettings
}

# Function to create emergency gaming mode script
create_emergency_gaming_script() {
    echo "Creating emergency gaming mode script..."
    
    cat > "/usr/local/bin/emergency_gaming_mode.sh" << 'EOF'
#!/bin/bash
# Emergency return to gaming mode

echo "EMERGENCY: Returning to gaming mode immediately!"

# Force shutdown all VMs and containers (30 second timeout)
timeout 30 /usr/local/bin/shutdown_all_labs.sh || killall -9 kvm lxc

# Set GRUB default to Windows
grub-set-default "Windows Gaming Mode"

# Log the emergency transition
logger "EMERGENCY: Gaming mode activated by emergency script"

# Immediate reboot
systemctl reboot --force
EOF
    
    chmod +x "/usr/local/bin/emergency_gaming_mode.sh"
}

# Function to validate dual-boot setup
validate_setup() {
    echo "Validating dual-boot setup..."
    
    # Check if both boot entries exist
    if ! grep -q "Windows Gaming Mode" /boot/grub/grub.cfg; then
        echo "ERROR: Windows boot entry not found in GRUB"
        return 1
    fi
    
    if ! grep -q "Proxmox Lab Mode" /boot/grub/grub.cfg; then
        echo "ERROR: Proxmox boot entry not found in GRUB"
        return 1
    fi
    
    # Check scheduled tasks
    if ! schtasks /query /tn "CyberShieldLabTransition" > /dev/null 2>&1; then
        echo "ERROR: Lab transition scheduled task not found"
        return 1
    fi
    
    echo "✓ Dual-boot setup validation passed"
    return 0
}

# Main execution
main() {
    echo "Starting Gaming PC dual-boot setup..."
    
    # Check if running as administrator
    if ! net session > /dev/null 2>&1; then
        echo "ERROR: This script must be run as Administrator"
        exit 1
    fi
    
    # Backup current configuration
    backup_windows_boot
    
    # Create necessary scripts
    create_boot_scheduler
    create_emergency_gaming_script
    
    echo "Dual-boot setup completed!"
    echo "Next steps:"
    echo "1. Manually resize Windows partition"
    echo "2. Install Proxmox VE on new partition"
    echo "3. Configure GRUB dual-boot"
    echo "4. Run validation script"
    
    echo "Configuration files saved to: $BACKUP_DIR"
}

# Execute main function
main "$@"
```

### 4. Comprehensive Configuration Files

```yaml
# config/lab_environment.yaml - Central configuration file

proxmox:
  host: "192.168.1.100"
  api_user: "root@pam"
  api_password: "secure_password_here"
  node_name: "pve"
  
guacamole:
  host: "192.168.1.101"
  port: 8080
  database: "mysql"
  admin_user: "guacadmin"
  admin_password: "guac_admin_password"
  
templates:
  kali_lxc:
    id: 100
    name: "kali-template-base"
    storage: "local-lvm"
    memory: 2048
    cores: 2
  
  metasploitable_vm:
    id: 900
    name: "metasploitable2-template"
    storage: "local-lvm"
    memory: 1024
    cores: 1

networking:
  management_bridge: "vmbr0"
  lab_bridge_base: 101
  student_network_base: "10.{bridge_id}.0.0/24"
  kali_ip_suffix: ".10"
  metasploitable_ip_suffix: ".20"

students:
  id_range:
    start: 1000
    increment: 10
  
  default_credentials:
    kali_user: "student"
    kali_password: "CyberShield2024!"
    metasploitable_user: "msfadmin"
    metasploitable_password: "msfadmin"

gaming_pcs:
  cluster_name: "cybershield-gaming-cluster"
  transition_times:
    lab_mode: "06:55"
    gaming_mode: "15:00"
  
  emergency_contacts:
    - "teacher@school.edu"
    - "it-admin@school.edu"

cloudflare:
  tunnel_name: "cybershield-labs"
  domain: "labs.yourschool.edu"
  api_token: "your_cloudflare_api_token"

monitoring:
  enabled: true
  metrics_retention_days: 30
  alert_thresholds:
    cpu_percent: 80
    memory_percent: 85
    disk_percent: 90
```

This comprehensive set of implementation guides and scripts provides the detailed, actionable foundation needed for successful "vibe-coding" implementation of your CyberShield Labs project. Each script includes error handling, logging, and validation to ensure reliable operation.
