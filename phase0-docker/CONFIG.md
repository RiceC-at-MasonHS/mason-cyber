# Phase0 Docker Configuration

This file contains configuration details and notes for the Phase 0 Docker environment.

## Services

- `guac-db` (MySQL 8.0)
  - Env vars set in `docker-compose.yml` (MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD)
  - Data volume: `guac-db-data`

- `guacd` (Guacamole daemon)
  - Handles remote protocol translation

- `guacamole` (Tomcat + Guacamole web app)
  - GUACAMOLE_HOME is mapped from `guacamole/guacamole.properties` and `guacamole/initdb.sql`

- `kali-student1`, `kali-student2` (lightweight Kali containers)
  - Minimal tools installed to reduce memory usage
  - Student home directories are not committed to git; they are ignored in `.gitignore`

- `vulnerable-target1`, `vulnerable-target2`
  - Minimal vulnerable services to practice against

## Credentials

- Guacamole default admin (development only):
  - user: `guacadmin`
  - pass: `guacadmin`

- MySQL (local dev): see `docker-compose.yml` environment variables. **Do not use these in production.**

## Network

- All containers are attached to internal Docker networks defined in `docker-compose.yml`.
- Guacamole is exposed on port 8080 to the host only.

## Known issues & notes

- Removed `nikto` from the Kali images due to compatibility/package issues during build; if you need web scanning, use `nikto` from a separate environment or install manually inside the running container.
- If services fail to start, check `docker-compose logs <service>` and `docker stats` for resource saturation.
- For WSL, ensure Docker Desktop WSL integration is enabled and the Linux distro has access to mounted Windows files.

## Customization

- To add tools to the Kali images: edit `phase0-docker/kali-lite/Dockerfile` and rebuild with `docker-compose build <service>`.
- To increase resources for a container, add resource limits in `docker-compose.yml` (deploy.resources or mem_limit) and rebuild.

## Security

- This environment is for educational sandboxing only. Do not expose it to the public internet without proper access controls (Cloudflare Access, VPN, or firewall rules).
- Change all default credentials before any real deployment.

## Troubleshooting commands

```bash
# Show logs for guacamole
docker-compose logs guacamole

# Show container resource usage
docker stats --no-stream

# Rebuild a single image
docker-compose build kali-student1

# Recreate containers
docker-compose up -d --force-recreate
```
