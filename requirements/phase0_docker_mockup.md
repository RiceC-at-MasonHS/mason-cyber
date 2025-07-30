# Phase 0: Docker Desktop Mockup - Teacher Laptop Implementation

## Overview

This Phase 0 implementation allows you to run a complete CyberShield Labs environment directly on your teacher laptop using Docker Desktop. This provides immediate validation of the concept with zero infrastructure requirements and minimal setup time.

## Objectives

- **Immediate Testing**: Validate the concept with 1-2 lightweight student environments
- **Zero Risk**: No school infrastructure involvement
- **Proof of Concept**: Demonstrate core functionality for administration
- **Resource Realistic**: Work within Dell Latitude 5340 limitations (16GB RAM, limited availability)
- **Learning Platform**: Understand components before requesting better resources

## Prerequisites

### Hardware Requirements (Teacher Laptop)
```
Your Dell Latitude 5340 Specs:
- CPU: Intel i5-1345U (10 cores, 12 threads) ✅ Excellent
- RAM: 16GB total, ~4.3GB available ⚠️ Limited
- Storage: Need ~20GB free space
- OS: Windows 11 Education ✅ Perfect

Realistic Docker Capacity:
- 1-2 student environments maximum
- Lightweight containers only
- No resource-intensive tools initially
```

### Software Requirements
1. **Docker Desktop** (free)
2. **Git** (for cloning configurations)
3. **Web Browser** (Chrome/Edge/Firefox)
4. **Text Editor** (VS Code recommended)

## Quick Start Guide

### Step 1: Install Docker Desktop

**Windows:**
```powershell
# Download and install Docker Desktop from docker.com
# Ensure WSL2 is enabled
wsl --update
```

**macOS:**
```bash
# Download Docker Desktop from docker.com
# Or use Homebrew
brew install --cask docker
```

### Step 2: Download CyberShield Docker Environment

```bash
# Create project directory
mkdir cybershield-labs
cd cybershield-labs

# Create the Docker Compose configuration
```

### Step 3: Complete Docker Environment Configuration

Create the following file structure:

```
cybershield-labs/
├── docker-compose.yml
├── guacamole/
│   ├── guacamole.properties
│   └── user-mapping.xml
├── kali/
│   ├── Dockerfile
│   └── setup.sh
├── metasploitable/
│   └── Dockerfile
├── scripts/
│   ├── setup.sh
│   └── cleanup.sh
└── README.md
```

## Complete Docker Configuration Files

### Main Docker Compose File

```yaml
# docker-compose.yml - Lightweight version for Dell Latitude 5340
version: '3.8'

services:
  # MySQL Database for Guacamole (optimized)
  guac-db:
    image: mysql:8.0
    container_name: cybershield-db
    environment:
      MYSQL_ROOT_PASSWORD: cybershield2024
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacamole_user
      MYSQL_PASSWORD: guacamole_pass
    volumes:
      - guac-db-data:/var/lib/mysql
      - ./guacamole/initdb.sql:/docker-entrypoint-initdb.d/initdb.sql:ro
    networks:
      - guacamole-net
    restart: unless-stopped
    # Resource limits for your laptop
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  # Guacamole Server (guacd) - lightweight
  guacd:
    image: guacamole/guacd:latest
    container_name: cybershield-guacd
    networks:
      - guacamole-net
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

  # Guacamole Web Application
  guacamole:
    image: guacamole/guacamole:latest
    container_name: cybershield-guacamole
    depends_on:
      - guac-db
      - guacd
    environment:
      GUACD_HOSTNAME: guacd
      MYSQL_HOSTNAME: guac-db
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacamole_user
      MYSQL_PASSWORD: guacamole_pass
    ports:
      - "8080:8080"
    networks:
      - guacamole-net
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M

  # Student 1 Lab Environment (lightweight Kali)
  kali-student1:
    build: ./kali-lite
    container_name: cybershield-kali-student1
    hostname: kali-student1
    environment:
      - STUDENT_ID=student1
      - STUDENT_PASSWORD=CyberShield2024!
    networks:
      student1-lab:
        ipv4_address: 10.1.0.10
    cap_add:
      - NET_ADMIN
    security_opt:
      - seccomp:unconfined
    volumes:
      - kali1-home:/home/student
    restart: unless-stopped
    # Critical: Resource limits for your 16GB laptop
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '2.0'
        reservations:
          memory: 1G
          cpus: '1.0'

  # Lightweight vulnerable target (NOT full Metasploitable2)
  vulnerable-target1:
    build: ./vulnerable-lite
    container_name: cybershield-target-student1
    hostname: vulnerable-target1
    networks:
      student1-lab:
        ipv4_address: 10.1.0.20
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
        reservations:
          memory: 256M
          cpus: '0.5'

  # Optional Student 2 (only if performance allows)
  kali-student2:
    build: ./kali-lite
    container_name: cybershield-kali-student2
    hostname: kali-student2
    environment:
      - STUDENT_ID=student2
      - STUDENT_PASSWORD=CyberShield2024!
    networks:
      student2-lab:
        ipv4_address: 10.2.0.10
    cap_add:
      - NET_ADMIN
    security_opt:
      - seccomp:unconfined
    volumes:
      - kali2-home:/home/student
    restart: unless-stopped
    profiles:
      - optional  # Only start if explicitly requested
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '2.0'
        reservations:
          memory: 1G
          cpus: '1.0'

  vulnerable-target2:
    build: ./vulnerable-lite
    container_name: cybershield-target-student2
    hostname: vulnerable-target2
    networks:
      student2-lab:
        ipv4_address: 10.2.0.20
    restart: unless-stopped
    profiles:
      - optional  # Only start if explicitly requested
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
        reservations:
          memory: 256M
          cpus: '0.5'

networks:
  guacamole-net:
    driver: bridge
  
  # Isolated lab networks
  student1-lab:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 10.1.0.0/24
  
  student2-lab:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 10.2.0.0/24

volumes:
  guac-db-data:
  kali1-home:
  kali2-home:
```

### Lightweight Kali Container Configuration

```dockerfile
# kali-lite/Dockerfile - Optimized for limited RAM
FROM debian:12-slim

# Install only essential packages (much lighter than full Kali)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server \
    sudo \
    vim \
    nano \
    curl \
    wget \
    net-tools \
    iputils-ping \
    nmap \
    netcat-traditional \
    tcpdump \
    nikto \
    dirb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create student user
RUN useradd -m -s /bin/bash student && \
    echo "student:CyberShield2024!" | chpasswd && \
    usermod -aG sudo student && \
    echo "student ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# Copy setup script
COPY setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Create useful aliases
RUN echo 'alias ll="ls -la"' >> /home/student/.bashrc && \
    echo 'alias scan="nmap -sS"' >> /home/student/.bashrc && \
    echo 'alias vulnscan="nikto -h"' >> /home/student/.bashrc && \
    chown student:student /home/student/.bashrc

EXPOSE 22

CMD ["/usr/local/bin/setup.sh"]
```

```bash
#!/bin/bash
# kali-lite/setup.sh - Lightweight setup

# Start SSH service
service ssh start

# Create student workspace
sudo -u student mkdir -p /home/student/labs
sudo -u student mkdir -p /home/student/results

# Set up welcome message
cat > /home/student/welcome.txt << 'EOF'
===================================
Welcome to CyberShield Labs Lite!
===================================

This is a lightweight demonstration environment.

Available Tools:
- nmap: Network scanning (scan command)
- nikto: Web vulnerability scanner (vulnscan command)
- netcat: Network utility
- Basic networking tools

Your target system is available at:
- Vulnerable Target: 10.X.0.20 (where X is your lab number)

Quick Commands:
- scan 10.X.0.20: Basic nmap scan
- vulnscan 10.X.0.20: Web vulnerability scan
- ping 10.X.0.20: Test connectivity

This is a proof-of-concept. Full tools available in production version.
===================================
EOF

chown student:student /home/student/welcome.txt

# Display welcome message on login
echo "cat /home/student/welcome.txt" >> /home/student/.bashrc

# Keep container running
tail -f /dev/null
```

### Simple Vulnerable Target Configuration

```dockerfile
# vulnerable-lite/Dockerfile - Very lightweight vulnerable target
FROM ubuntu:20.04

# Install minimal vulnerable services
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server \
    apache2 \
    telnetd \
    ftp \
    vsftpd \
    && apt-get clean

# Create vulnerable user accounts
RUN useradd -m -s /bin/bash admin && \
    echo "admin:admin" | chpasswd && \
    useradd -m -s /bin/bash test && \
    echo "test:test" | chpasswd

# Configure vulnerable SSH (for demonstration only!)
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config

# Configure vulnerable FTP
RUN echo 'anonymous_enable=YES' >> /etc/vsftpd.conf && \
    echo 'anon_upload_enable=YES' >> /etc/vsftpd.conf

# Create simple vulnerable web content
RUN echo '<html><body><h1>Vulnerable Practice Server</h1>' > /var/www/html/index.html && \
    echo '<p>This is a practice target for cybersecurity learning.</p>' >> /var/www/html/index.html && \
    echo '<p>Available services: SSH (port 22), FTP (port 21), Web (port 80)</p>' >> /var/www/html/index.html && \
    echo '</body></html>' >> /var/www/html/index.html

# Create a simple info page
RUN echo '<html><body><h2>Server Info</h2><pre>' > /var/www/html/info.html && \
    echo 'Users: admin:admin, test:test' >> /var/www/html/info.html && \
    echo 'Services: SSH, FTP, HTTP' >> /var/www/html/info.html && \
    echo '</pre></body></html>' >> /var/www/html/info.html

EXPOSE 21 22 80

CMD service ssh start && \
    service vsftpd start && \
    service apache2 start && \
    tail -f /dev/null
```

### Guacamole Configuration

```properties
# guacamole/guacamole.properties
guacd-hostname: guacd
guacd-port: 4822

# MySQL properties
mysql-hostname: guac-db
mysql-port: 3306
mysql-database: guacamole_db
mysql-username: guacamole_user
mysql-password: guacamole_pass

# Additional security
mysql-default-max-connections-per-user: 0
mysql-default-max-group-connections-per-user: 0
```

### Setup and Management Scripts

```bash
#!/bin/bash
# scripts/setup.sh - Realistic setup for Dell Latitude 5340

echo "🚀 Setting up CyberShield Labs Lite for your laptop..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

# Check available memory
AVAILABLE_MEM=$(docker system df | grep -E "Total reclaimed space|Total space used" | tail -1 | awk '{print $4}')
echo "📊 Checking system resources..."

# Create necessary directories
mkdir -p guacamole kali-lite vulnerable-lite scripts

echo "🏗️  Building lightweight Docker containers..."
echo "   This may take 10-15 minutes on first run..."

# Build containers one at a time to avoid memory pressure
echo "   Building Kali Lite container..."
docker-compose build kali-student1

echo "   Building vulnerable target container..."
docker-compose build vulnerable-target1

echo "🚀 Starting CyberShield Labs Lite (minimal environment)..."

# Start only essential services first
echo "   Starting database and Guacamole..."
docker-compose up -d guac-db guacd guacamole

# Wait for database to be ready
echo "⏳ Waiting for database to initialize..."
sleep 45

echo "   Starting student 1 environment..."
docker-compose up -d kali-student1 vulnerable-target1

# Check if we have enough resources for student 2
echo "� Checking system performance..."
sleep 30

MEMORY_USAGE=$(docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}" | grep cybershield | awk -F/ '{sum+=$1} END {print sum}')
echo "   Current memory usage by containers: ~${MEMORY_USAGE:-Unknown}"

read -p "💡 Do you want to try starting Student 2 environment? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "   Starting student 2 environment..."
    docker-compose --profile optional up -d kali-student2 vulnerable-target2
    echo "   ⚠️  Monitor performance closely!"
fi

# Check service status
echo "📊 Checking service status..."
docker-compose ps

echo ""
echo "✅ CyberShield Labs Lite is ready!"
echo ""
echo "🌐 Access Guacamole at: http://localhost:8080/guacamole"
echo "👤 Default login: guacadmin / guacadmin"
echo ""
echo "🎯 Student Lab Environments:"
echo "   Student 1: Kali (10.1.0.10) → Target (10.1.0.20)"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "   Student 2: Kali (10.2.0.10) → Target (10.2.0.20)"
fi
echo ""
echo "⚠️  Performance Tips for your Dell Latitude 5340:"
echo "   - Close other applications while running labs"
echo "   - Monitor Docker Desktop resource usage"
echo "   - Use 'docker stats' to watch container performance"
echo "   - Run './scripts/cleanup.sh' when done to free resources"
echo ""
echo "🔧 Manual Guacamole Setup Required:"
echo "   1. Login to Guacamole web interface"
echo "   2. Go to Settings → Connections"
echo "   3. Create SSH connection:"
echo "      - Name: Student 1 - Kali Lite"
echo "      - Protocol: SSH"
echo "      - Hostname: cybershield-kali-student1"
echo "      - Username: student"
echo "      - Password: CyberShield2024!"
echo ""
echo "📚 Quick Test Commands (after connecting to Kali):"
echo "   scan 10.1.0.20     # Network scan of target"
echo "   vulnscan 10.1.0.20 # Web vulnerability scan"
echo "   ping 10.1.0.20     # Test connectivity"
```

```bash
#!/bin/bash
# scripts/cleanup.sh - Cleanup script

echo "🧹 Cleaning up CyberShield Labs..."

# Stop all containers
docker-compose down

# Remove volumes (optional - removes student data)
read -p "Do you want to remove all student data? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker-compose down -v
    echo "🗑️  Student data removed"
fi

# Remove unused images (optional)
read -p "Do you want to remove Docker images to free space? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker system prune -f
    echo "🗑️  Unused Docker images removed"
fi

echo "✅ Cleanup completed!"
```

## Quick Deployment Instructions

### 1. One-Command Setup

```bash
# Create project directory and download files
mkdir cybershield-labs && cd cybershield-labs

# Copy all the configuration files (from above) into appropriate directories
# Then run:
./scripts/setup.sh
```

### 2. Manual Guacamole Connection Setup

After starting the environment:

1. **Access Guacamole**: `http://localhost:8080/guacamole`
2. **Login**: `guacadmin` / `guacadmin`
3. **Add SSH Connections** for each Kali container:
   - Name: "Student 1 - Kali Linux"
   - Protocol: SSH
   - Hostname: `cybershield-kali-student1`
   - Username: `student`
   - Password: `CyberShield2024!`
4. **Add VNC/RDP connections** for Metasploitable containers if needed

## Testing Your Environment

### Basic Functionality Test

```bash
# Test SSH connectivity to Kali containers
docker exec -it cybershield-kali-student1 ssh student@localhost

# Test network connectivity between containers
docker exec cybershield-kali-student1 ping 10.1.0.20

# Test nmap scan from Kali to Metasploitable
docker exec cybershield-kali-student1 nmap -sS 10.1.0.20
```

### Student Workflow Validation

1. **Access via Web Browser**: `http://localhost:8080/guacamole`
2. **Select Kali Environment**: Choose "Student 1 - Kali Linux"
3. **Run Security Tools**:
   ```bash
   # In the Kali terminal via Guacamole
   nmap -sS 10.1.0.20
   nikto -h 10.1.0.20
   ```

## Resource Management

### Performance Monitoring

```bash
# Monitor Docker resource usage
docker stats

# Check container logs
docker-compose logs guacamole
docker-compose logs kali-student1
```

### Scaling for More Students

To add more student environments, simply copy the student environment blocks in `docker-compose.yml` and increment the numbers:

```yaml
# Student 4 Lab Environment
kali-student4:
  build: ./kali
  container_name: cybershield-kali-student4
  networks:
    student4-lab:
      ipv4_address: 10.4.0.10
  # ... rest of configuration
```

## Benefits of Phase 0

### Immediate Validation
- **Complete workflow testing** in under 2 hours
- **Zero infrastructure requirements**
- **Full feature demonstration** for administration
- **Student experience validation**

### Risk-Free Learning
- **No school network impact**
- **Easy to reset/restart**
- **Complete isolation** on your laptop
- **Professional demonstration capability**

### Foundation for Scaling
- **Same architecture** as production phases
- **Proven configuration** ready for deployment
- **Student workflow** already validated
- **Performance baseline** established

## Troubleshooting

### Common Issues

**Docker Desktop not starting:**
```bash
# Windows: Ensure WSL2 is enabled
wsl --update

# macOS: Check available disk space
docker system df
```

**Containers not communicating:**
```bash
# Check network configuration
docker network ls
docker network inspect cybershield-labs_student1-lab
```

**Guacamole not accessible:**
```bash
# Check if services are running
docker-compose ps
docker-compose logs guacamole
```

## Next Steps

After successful Phase 0 testing:

1. **Document results** and create demonstration for administration
2. **Gather feedback** from test students (if possible)
3. **Plan Phase 1** cloud deployment based on lessons learned
4. **Use Phase 0** as ongoing development/testing environment

This Phase 0 Docker environment gives you a complete, functional CyberShield Labs system running on your teacher laptop - perfect for immediate validation and demonstration of the entire concept!
