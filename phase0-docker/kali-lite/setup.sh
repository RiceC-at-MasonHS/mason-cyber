#!/bin/bash
# kali-lite/setup.sh - Lightweight setup for Phase 0

# Start SSH service
service ssh start

# Create student workspace
sudo -u student mkdir -p /home/student/labs
sudo -u student mkdir -p /home/student/results
sudo -u student mkdir -p /home/student/scans

# Set up welcome message
cat > /home/student/welcome.txt << 'EOF'
===================================
Welcome to CyberShield Labs Lite!
===================================

This is a lightweight demonstration environment optimized for your Dell Latitude 5340.

Available Tools:
- nmap: Network scanning (scan command)
- nikto: Web vulnerability scanner (vulnscan command) 
- netcat: Network utility
- tcpdump: Packet capture
- dirb: Directory brute-forcer
- Basic networking tools

Your target system is available at:
- Vulnerable Target: 10.X.0.20 (where X is your lab number)

Quick Commands:
- scan 10.1.0.20         # Basic nmap scan
- vulnscan 10.1.0.20     # Web vulnerability scan
- portscan 10.1.0.20     # Full port scan
- quickscan 10.1.0.20    # Fast scan
- ping 10.1.0.20         # Test connectivity
- ./cyber-toolkit.sh     # Show all available commands

Example Lab Workflow:
1. ping 10.1.0.20                    # Test connectivity
2. quickscan 10.1.0.20               # Quick port discovery
3. scan 10.1.0.20                    # Detailed scan
4. vulnscan 10.1.0.20                # Web vulnerability assessment
5. dirb http://10.1.0.20             # Directory discovery

This is a proof-of-concept. Full tools available in production version.
===================================
EOF

chown student:student /home/student/welcome.txt

# Display welcome message on login
echo "cat /home/student/welcome.txt" >> /home/student/.bashrc

# Create some example scan result files for demonstration
sudo -u student echo "# Example scan results will be saved here" > /home/student/scans/README.txt
sudo -u student echo "# Lab exercises and notes" > /home/student/labs/README.txt
sudo -u student echo "# Analysis results and findings" > /home/student/results/README.txt

# Keep container running
tail -f /dev/null
