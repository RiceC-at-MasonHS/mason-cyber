# WSL Setup Guide for CyberShield Labs Phase 0

## Prerequisites Setup

### 1. Install WSL2 (if not already installed)
```bash
# In Windows PowerShell as Administrator:
wsl --install
# Reboot when prompted
```

### 2. Install Docker Desktop
1. Download from https://www.docker.com/products/docker-desktop/
2. During installation, ensure "Use WSL 2 instead of Hyper-V" is checked
3. After installation, open Docker Desktop
4. Go to Settings → Resources → WSL Integration
5. Enable integration with your WSL distribution

### 3. Verify Setup
```bash
# Open WSL terminal and test:
docker --version
docker-compose --version
docker info
```

## Running CyberShield Labs

### 1. Navigate to Project Directory
```bash
# In WSL terminal:
cd /mnt/c/Users/ricec/Documents/workspace/mason-cyber/phase0-docker
```

### 2. Make Scripts Executable
```bash
chmod +x scripts/*.sh
```

### 3. Start Your Cyber Lab
```bash
./scripts/setup.sh
```

### 4. Access Web Interface
- Open Windows browser to: http://localhost:8080/guacamole
- Login: `guacadmin` / `guacadmin`

## Daily Usage

### Starting Your Lab Session
```bash
cd /mnt/c/Users/ricec/Documents/workspace/mason-cyber/phase0-docker
./scripts/setup.sh    # or ./scripts/restart.sh if already setup
```

### Checking Lab Status
```bash
./scripts/status.sh
```

### Ending Lab Session
```bash
./scripts/cleanup.sh
```

## Tips for WSL + Docker

### Resource Management
- Docker Desktop uses WSL2 backend automatically
- Memory limits are shared between WSL and Docker
- Monitor usage with: `docker stats`

### File Access
- WSL can access Windows files via `/mnt/c/`
- Windows can access WSL files via `\\wsl$\`
- Keep project files on Windows side for easy editing

### Networking
- `localhost` works the same in WSL and Windows
- Guacamole web interface accessible from Windows browser
- Students access via regular web browsers (perfect for Chromebooks!)

## Troubleshooting

### Docker Not Found
```bash
# Ensure Docker Desktop WSL integration is enabled
# Docker Desktop → Settings → Resources → WSL Integration
```

### Permission Errors
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Fix Docker socket permissions (if needed)
sudo usermod -aG docker $USER
# Then logout and login to WSL
```

### Can't Access Web Interface
```bash
# Check if services are running
./scripts/status.sh

# Restart if needed
./scripts/restart.sh
```

This setup gives you the best of both worlds: Linux containers running efficiently in WSL while maintaining easy access from your Windows environment!
