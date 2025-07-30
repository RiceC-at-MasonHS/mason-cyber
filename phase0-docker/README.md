# CyberShield Labs - Phase 0 Docker Implementation

> **Proof-of-Concept Cybersecurity Lab for High School Students**  
> Runs on teacher's Dell Latitude 5340 (16GB RAM) using WSL + Docker

## Quick Start (WSL Required)

### Prerequisites
1. **Windows Subsystem for Linux (WSL2)** - [Install Guide](https://docs.microsoft.com/en-us/windows/wsl/install)
2. **Docker Desktop** with WSL2 integration - [Download](https://www.docker.com/products/docker-desktop/)

### One-Command Setup
```bash
# Open WSL terminal, navigate to this directory, then:
./scripts/setup.sh
```

### Access Your Lab
- **Web Interface**: http://localhost:8080/guacamole
- **Login**: `guacadmin` / `guacadmin`
- **Students access via web browser** (perfect for Chromebooks!)

---

## Available Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `./scripts/setup.sh` | Initial deployment | First time setup |
| `./scripts/status.sh` | Check system health | Troubleshooting |
| `./scripts/restart.sh` | Restart all services | After system sleep/reboot |
| `./scripts/cleanup.sh` | Remove everything | When finished testing |

---

## What's Included

### 🎯 Student Environments
- **Kali Student 1**: Lightweight penetration testing environment (512MB RAM)
- **Vulnerable Target 1**: Practice target with intentional vulnerabilities (256MB RAM)
- **Kali Student 2**: Optional second environment (for testing capacity)

### 🌐 Web Access Gateway
- **Apache Guacamole**: Browser-based remote desktop
- **No SSH required**: Perfect for Chromebook limitations
- **Network isolation**: Students can't break out of their sandbox

### 🛠️ Pre-installed Tools
Each Kali environment includes:
- `nmap` - Network scanning
- `nikto` - Web vulnerability scanner
- `hydra` - Password cracking
- `metasploit` - Penetration testing framework
- Custom aliases for easy learning

---

## System Requirements & Performance

### Your Dell Latitude 5340 Specs ✅
- **CPU**: Intel i5-1345U (10 cores) - Excellent
- **RAM**: 16GB - Perfect for 2-3 student environments
- **Storage**: ~5GB needed for all containers

### Expected Resource Usage
- **Student 1 Only**: ~3GB RAM (recommended for demos)
- **Student 1 + 2**: ~4-5GB RAM (max capacity test)
- **CPU Usage**: <20% during normal lab activities

### Performance Tips
- Close other applications during labs
- Monitor with: `docker stats`
- Use single student environment for presentations
- Enable 2nd student only for capacity testing

---

## Network Architecture

```
Internet
    ↓
Docker Host (your laptop)
    ↓
Guacamole Web Interface (:8080)
    ↓
┌─────────────────┬─────────────────┐
│  Student Lab 1  │  Student Lab 2  │
│                 │   (optional)    │
│ Kali: 10.1.0.10 │ Kali: 10.2.0.10 │
│   ↓             │   ↓             │
│ Target:10.1.0.20│ Target:10.2.0.20│
└─────────────────┴─────────────────┘
```

**Security Features:**
- Each student lab is network-isolated
- No access to host system or internet
- Safe practice environment for attack techniques

---

## Educational Value

### For Students
- **Real cybersecurity tools** in safe environment
- **Browser-based access** works on any device
- **Immediate feedback** from vulnerable targets
- **Progressive difficulty** from basic scans to advanced exploitation

### For Teachers
- **Zero setup** for students (just open browser)
- **Complete control** over lab environment
- **Easy monitoring** of student activities
- **Scalable approach** for larger deployments

---

## Troubleshooting

### Container Won't Start
```bash
# Check Docker status
docker info

# Check available resources
docker system df

# View container logs
docker-compose logs [service-name]
```

### Web Interface Won't Load
```bash
# Wait 2-3 minutes after startup
./scripts/status.sh

# Check if port 8080 is available
netstat -an | grep 8080

# Restart services
./scripts/restart.sh
```

### Performance Issues
```bash
# Check resource usage
docker stats

# Use single student environment
docker-compose down
docker-compose up -d guac-db guacd guacamole kali-student1 vulnerable-target1
```

### WSL Integration Issues
```bash
# Ensure Docker Desktop WSL integration is enabled
# Settings → Resources → WSL Integration → Enable for your distro
```

---

## Next Steps After Phase 0

### If This Works Well ✅
1. **Phase 1**: Deploy to cloud for classroom access
2. **Phase 2**: Set up dedicated Proxmox server
3. **Gaming PC Extension**: Utilize school computers during off-hours

### Administration Demo
Use this Phase 0 to demonstrate to:
- **Principal**: Show educational value and safety
- **IT Director**: Prove technical feasibility
- **Other Teachers**: Showcase ease of use

### Student Testing
- Test with 1-2 students first
- Verify Chromebook compatibility
- Measure engagement and learning outcomes

---

## Security & Safety

### What Students CAN Do ✅
- Practice ethical hacking techniques
- Learn cybersecurity fundamentals
- Safely attack vulnerable targets
- Use professional security tools

### What Students CANNOT Do ❌
- Access teacher's laptop or network
- Reach the internet from lab environment
- Install malware or cause real damage
- Access other students' environments

---

## File Structure

```
phase0-docker/
├── README.md                    # This file
├── docker-compose.yml           # Container orchestration
├── scripts/
│   ├── setup.sh                # Initial deployment
│   ├── status.sh               # Health monitoring
│   ├── restart.sh              # Service restart
│   └── cleanup.sh              # Environment removal
├── kali-lite/
│   ├── Dockerfile              # Lightweight Kali Linux
│   └── tools/                  # Custom security tools
├── vulnerable-lite/
│   ├── Dockerfile              # Practice target
│   └── vulnerabilities/        # Intentional security flaws
└── guacamole/
    ├── initdb.sql              # Database setup
    └── guacamole.properties     # Configuration
```

---

## Why This Approach Works

### ✅ **Chromebook Compatible**
Students only need a web browser - no special software or permissions required.

### ✅ **Teacher Controlled** 
Everything runs on your laptop - no complex network setup or IT department involvement.

### ✅ **Educationally Sound**
Real tools, real techniques, but in a completely safe sandbox environment.

### ✅ **Scalable Foundation**
Proves the concept for larger deployments without any infrastructure investment.

### ✅ **Resource Efficient**
Optimized specifically for your Dell Latitude 5340's capabilities.

---

## Support & Questions

- **Immediate Help**: Run `./scripts/status.sh` for diagnostics
- **Reset Everything**: Run `./scripts/cleanup.sh` then `./scripts/setup.sh`
- **Check Resources**: Use `docker stats` to monitor performance
- **Log Issues**: Use `docker-compose logs` to see detailed error messages

**Ready to launch your cybersecurity program? Just run `./scripts/setup.sh` and start teaching! 🚀**
