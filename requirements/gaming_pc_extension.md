# Gaming PC Lab Extension: Stealth Virtualization Infrastructure

## Project Overview

Leverage unused gaming computers during school hours to provide additional virtualization capacity for the CyberShield Labs project, while maintaining complete invisibility and zero impact on gaming functionality.

## Critical Requirements

- **100% Invisibility**: Solution must be completely transparent to gaming users
- **Zero Gaming Impact**: No performance degradation when PCs are used for gaming
- **Automated Operation**: Minimal manual intervention required
- **Remote Management**: Ability to manage lab infrastructure remotely
- **Quick Recovery**: Rapid transition back to gaming mode when needed

## Recommended Solution: Dual-Boot Proxmox Configuration

### Architecture Overview

```
Gaming PC Fleet (During School Hours)
├── Boot Option 1: Windows 11 Gaming Environment (Default)
├── Boot Option 2: Proxmox VE Lab Environment (Scheduled)
└── Network: Connected to school LAN for remote management
```

### Implementation Strategy

#### Phase 1: Initial Setup (Per Gaming PC)

1. **Disk Partitioning:**
   ```bash
   # Preserve existing Windows installation
   # Create new partition for Proxmox VE (minimum 100GB)
   # Maintain Windows boot as default
   ```

2. **Proxmox VE Installation:**
   - Install Proxmox on secondary partition
   - Configure GRUB bootloader with Windows default
   - Set up automated boot scheduling

3. **Network Configuration:**
   - Static IP assignment for each gaming PC in lab mode
   - Subnet isolation from gaming network traffic
   - Remote management interface setup

#### Phase 2: Automation Scripts

1. **School Day Transition Script (Windows):**
   ```powershell
   # Schedule daily reboot to Proxmox at 7:00 AM
   # Set GRUB default temporarily to Proxmox
   # Send notification to lab management system
   ```

2. **Gaming Mode Return Script (Proxmox):**
   ```bash
   # Scheduled shutdown of all VMs/containers at 3:00 PM
   # Reset GRUB default to Windows
   # Reboot to gaming environment
   ```

3. **Emergency Gaming Mode Script:**
   ```powershell
   # Immediate transition to Windows if gaming needed urgently
   # Graceful VM shutdown with state preservation
   # Quick reboot capability
   ```

#### Phase 3: Lab Infrastructure Deployment

1. **Distributed Proxmox Cluster:**
   - Each gaming PC becomes a Proxmox node during school hours
   - Centralized management interface
   - Load balancing across available nodes

2. **Student Lab Distribution:**
   - Spread student environments across multiple gaming PCs
   - Redundancy for hardware failures
   - Dynamic scaling based on available resources

3. **Resource Management:**
   - Automatic resource allocation per gaming PC specs
   - Performance monitoring and optimization
   - Storage management across nodes

## Technical Specifications

### Hardware Requirements Assessment

**Typical Gaming PC Specs (Assumed):**
- CPU: Intel i5/i7 or AMD Ryzen 5/7 (8+ cores)
- RAM: 16-32GB DDR4
- Storage: 1TB+ NVMe SSD
- GPU: Dedicated gaming GPU (can be passed through to VMs)
- Network: Gigabit Ethernet

**Virtualization Capacity per PC:**
- Concurrent Kali LXCs: 8-12 (2GB RAM each)
- Concurrent Metasploitable2 VMs: 4-6 (2GB RAM each)
- Total student labs per PC: 6-8 complete environments

### Network Architecture

```
School LAN
├── Gaming Network Segment (192.168.100.0/24)
│   └── Gaming PCs (Windows mode)
├── Lab Management Network (192.168.200.0/24)
│   └── Gaming PCs (Proxmox mode)
└── Student Lab Networks (10.x.y.0/24)
    └── Isolated lab environments
```

## Automation Framework

### Boot Management System

1. **Windows Scheduler Integration:**
   ```powershell
   # Daily task: Transition to lab mode
   schtasks /create /tn "LabModeTransition" /tr "powershell.exe -file lab_transition.ps1" /sc daily /st 06:55

   # Daily task: Return to gaming mode  
   # (Executed from Proxmox before shutdown)
   ```

2. **GRUB Configuration Management:**
   ```bash
   # Set temporary boot default
   grub-set-default "Proxmox VE GNU/Linux"
   grub-mkconfig -o /boot/grub/grub.cfg
   ```

3. **Health Monitoring:**
   - Automated checks for successful transitions
   - Alert system for failed boots or stuck transitions
   - Remote recovery procedures

### Student Lab Orchestration

1. **Dynamic Lab Allocation:**
   ```python
   # Pseudo-code for lab distribution
   def allocate_student_lab(student_id, available_nodes):
       # Find node with sufficient resources
       # Create isolated network segment
       # Deploy Kali LXC and Metasploitable2 VM
       # Update Guacamole connection database
   ```

2. **Cross-Node Guacamole Integration:**
   - Central Guacamole server with connections to all gaming PC nodes
   - Dynamic connection management as nodes come online/offline
   - Load balancing for optimal performance

## Risk Mitigation

### Gaming Mode Protection

1. **Boot Priority Safeguards:**
   - Windows remains default boot option
   - Automatic revert to Windows if boot fails
   - Physical override switches/procedures

2. **Storage Isolation:**
   - Completely separate partitions
   - No file system sharing between modes
   - Gaming data remains untouched

3. **Performance Monitoring:**
   - Baseline gaming performance metrics
   - Automated testing after lab mode sessions
   - Alert system for any degradation

### Emergency Procedures

1. **Immediate Gaming Access:**
   ```bash
   # Emergency shutdown script
   /usr/local/bin/emergency_gaming_mode.sh
   # - Graceful VM shutdown (30 seconds max)
   # - Force shutdown if needed
   # - Reset boot to Windows
   # - Immediate reboot
   ```

2. **Remote Management:**
   - IPMI/iLO access where available
   - Wake-on-LAN for remote power management
   - Network-based emergency controls

## Benefits of Gaming PC Extension

### Capacity Multiplication
- 20 gaming PCs = 120-160 concurrent student lab environments
- Distributed load reduces single points of failure
- Scalable based on actual gaming PC availability

### Cost Efficiency
- Leverage existing high-performance hardware
- No additional server purchase required
- Maximize ROI on gaming computer investment

### Educational Opportunities
- Students learn about distributed computing
- Real-world cloud-like infrastructure experience
- Hybrid cloud concepts demonstration

## Implementation Timeline

**Week 1-2: Proof of Concept**
- Set up dual-boot on 1-2 test gaming PCs
- Validate invisibility and performance requirements
- Test automation scripts

**Week 3-4: Pilot Deployment**
- Deploy on 5-6 gaming PCs
- Test distributed Proxmox cluster
- Validate Guacamole integration

**Week 5-6: Full Deployment**
- Roll out to all available gaming PCs
- Complete automation framework
- Staff training and documentation

**Week 7+: Operation and Optimization**
- Monitor performance and reliability
- Optimize resource allocation
- Expand lab offerings

## Success Metrics

### Technical Metrics
- 100% successful daily transitions between modes
- Zero gaming performance degradation
- 99%+ lab environment availability during school hours
- <30 second emergency transition to gaming mode

### Educational Metrics
- Increased concurrent student capacity
- Reduced wait times for lab access
- Enhanced learning opportunities through distributed systems exposure

This approach transforms your gaming PC fleet into a powerful, distributed virtualization infrastructure while maintaining complete transparency to gaming users.
