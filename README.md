# mason-cyber

CyberShield Labs — a lightweight cybersecurity lab for classroom use. This repository contains documentation and a Phase 0 Docker-based proof-of-concept you can run on a teacher laptop (WSL + Docker).

## Current status (Phase 0)
- Phase 0: Docker-based proof-of-concept is implemented in `phase0-docker/` and is tested for WSL/Docker Desktop on a Dell Latitude 5340 (16GB RAM).
- Provides a browser-accessible lab via Apache Guacamole so students can use Chromebooks without local installs.

## Quick start (recommended: WSL2 + Docker Desktop)
1. Enable WSL2 and install a Linux distro (Ubuntu recommended).
2. Install Docker Desktop and enable WSL2 integration.
3. From a WSL shell, open the project directory (Windows path mounted under `/mnt/c/...`):

```bash
cd /mnt/c/Users/ricec/Documents/workspace/mason-cyber/phase0-docker
chmod +x scripts/*.sh
./scripts/setup.sh
```

4. Open your browser to `http://localhost:8080/guacamole` and log in with the default (guacadmin / guacadmin).

For more details on Phase 0, troubleshooting, and WSL-specific instructions, see `phase0-docker/README.md` and `phase0-docker/WSL-SETUP.md`.

## Repository layout (high level)
- `phase0-docker/` — Phase 0 Docker compose, container Dockerfiles, guacamole configs, and management scripts (WSL-ready)
- `requirements/` — Project documentation, rollout plans, and architecture notes

## Next steps
- Validate Phase 0 with a small student test and collect performance metrics.
- If Phase 0 is successful, proceed to Phase 1 (cloud deployment) and Phase 2 (Proxmox server).

## Notes
- The repo `.gitignore` has been updated to exclude container data, secrets, and student artifacts — only configuration and scripts are tracked.

If you want I can open a PR for this branch or tag a release for Phase 0.