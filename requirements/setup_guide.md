# Setup Guide: CyberShield Labs Initial Deployment

This guide outlines the step-by-step process for setting up the CyberShield Labs environment.

## Phase 1: Proxmox VE Host Setup

1.  **Install Proxmox VE:**
    * Perform a fresh installation of Proxmox VE on the "extra server."
    * During installation, configure the primary network interface (`vmbr0`) with a static IP on your school's management LAN.
2.  **Configure Network Bridges (Isolated Lab Networks):**
    * Access the Proxmox Web UI (`https://<Proxmox_IP>:8006`).
    * Navigate to `Datacenter` -> `Node Name` -> `System` -> `Network`.
    * Click `Create` -> `Linux Bridge`.
    * **Do NOT** check "Autostart" or add a "Bridge port" for these. Leave "IPv4/IPv6" fields empty.
    * Create multiple such bridges, one for each anticipated concurrent lab. Use a consistent naming scheme, e.g., `vmbr101`, `vmbr102`, `vmbr103`, etc.
    * Apply the configuration changes and reboot the Proxmox host if prompted.
    * *(Self-note: Consider scripting this for bulk creation if many labs are needed.)*

## Phase 2: Apache Guacamole Server Deployment

1.  **Create Guacamole LXC Container:**
    * In Proxmox Web UI, click `Create CT`.
    * **Hostname:** `guacamole`
    * **Password:** Set a strong password.
    * **Template:** Select a Debian 12 (Bookworm) or Ubuntu LTS (e.g., 24.04) standard template.
    * **Disk Size:** Recommend 20-30GB.
    * **CPU Cores:** 2 cores.
    * **RAM:** 2GB minimum (adjust based on expected concurrent users).
    * **Network:** Assign a static IP address on `vmbr0` (your management network).
    * **Features:** Ensure `Nesting` is **NOT** enabled for Guacamole LXC (not needed for this specific setup, keep it simpler).
    * Start the Guacamole LXC.
2.  **Install Apache Guacamole:**
    * SSH into the new Guacamole LXC (from your admin workstation).
    * **Update System:** `sudo apt update && sudo apt upgrade -y`
    * **Install Dependencies (Guacamole Server):**
        ```bash
        sudo apt install -y build-essential libcairo2-dev libjpeg-turbo8-dev libpng-dev \
        libtool-bin libossp-uuid-dev libavcodec-dev libavutil-dev libswresample-dev \
        libwebp-dev libvncserver-dev libfreerdp-dev libssh2-1-dev libtelnet-dev \
        libssl-dev libpulse-dev libvorbis-dev libxrandr-dev libxfixes-dev \
        freerdp-x11
        ```
    * **Install Guacamole Client (Tomcat):**
        ```bash
        sudo apt install -y tomcat9 tomcat9-admin tomcat9-user
        ```
    * **Install Guacamole MySQL/PostgreSQL support (Recommended for user management):**
        * Install MySQL/MariaDB server or PostgreSQL server on the same LXC or a separate dedicated database LXC.
        * Install `libguac-client-mysql` (for MySQL/MariaDB) or `libguac-client-postgresql` (for PostgreSQL).
        * *For MySQL Example:* `sudo apt install -y mysql-server libguac-client-mysql`
    * **Download and Build Guacamole Server:**
        * Check Apache Guacamole's official website for the latest stable release.
        * Example (replace `1.x.x` with current version):
            ```bash
            GUAC_VERSION="1.x.x" # Get latest from guacamole.apache.org
            wget [https://apache.org/dyn/closer.lua?action=download&filename=guacamole/$](https://apache.org/dyn/closer.lua?action=download&filename=guacamole/$){GUAC_VERSION}/source/guacamole-server-${GUAC_VERSION}.tar.gz -O guacamole-server-${GUAC_VERSION}.tar.gz
            tar -xzf guacamole-server-${GUAC_VERSION}.tar.gz
            cd guacamole-server-${GUAC_VERSION}
            ./configure --with-systemd-dir=/etc/systemd/system --with-guacd-user=tomcat
            make
            sudo make install
            sudo ldconfig
            sudo systemctl enable guacd
            sudo systemctl start guacd
            ```
    * **Deploy Guacamole Web Application (`.war` file):**
        * Download the `.war` file:
            ```bash
            wget [https://apache.org/dyn/closer.lua?action=download&filename=guacamole/$](https://apache.org/dyn/closer.lua?action=download&filename=guacamole/$){GUAC_VERSION}/binary/guacamole-${GUAC_VERSION}.war -O /var/lib/tomcat9/webapps/guacamole.war
            ```
        * Create `GUACAMOLE_HOME`:
            ```bash
            sudo mkdir /etc/guacamole
            sudo chmod 755 /etc/guacamole
            ```
        * Create `guacamole.properties` (example for MySQL):
            ```bash
            sudo nano /etc/guacamole/guacamole.properties
            ```
            Add:
            ```properties
            guacd-hostname: localhost
            guacd-port: 4822
            auth-provider: net.sourceforge.guacamole.net.auth.mysql.MySQLAuthenticationProvider
            mysql-hostname: localhost
            mysql-port: 3306
            mysql-database: guacamole_db
            mysql-username: guacamole_user
            mysql-password: YOUR_GUACAMOLE_DB_PASSWORD
            ```
        * **Database Setup:** Create `guacamole_db` and `guacamole_user` in MySQL/MariaDB and import the Guacamole schema (scripts are in the `guacamole-server` source directory you downloaded).
        * Restart Tomcat: `sudo systemctl restart tomcat9`
    * **Test Guacamole:** From your admin workstation, open a browser to `http://<Guacamole_LXC_IP>:8080/guacamole/`. You should see the login page.
    * **Create Initial Guacamole Admin User:** Follow Guacamole's documentation for setting up the initial user via the database.

## Phase 3: Cloudflare Tunnel Configuration

1.  **Install `cloudflared`:**
    * On the Proxmox host (or a very small dedicated LXC/VM on `vmbr0`), install `cloudflared`.
    * Follow Cloudflare's official guide: [https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/install-and-setup/tunnel-guide/](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/install-and-setup/tunnel-guide/)
    * Example for Debian/Ubuntu:
        ```bash
        curl -L --output cloudflared.deb [https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb](https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb)
        sudo dpkg -i cloudflared.deb
        sudo cloudflared service install
        ```
2.  **Authenticate `cloudflared`:**
    * `cloudflared tunnel login`
    * This will open a browser window for you to log into your Cloudflare account and select your domain.
3.  **Create a Tunnel:**
    * `cloudflared tunnel create CyberShield-Labs-Tunnel`
    * Note the Tunnel ID.
4.  **Configure Tunnel Routing:**
    * Create a `config.yml` file for your tunnel (e.g., in `/etc/cloudflared/config.yml`):
        ```yaml
        tunnel: <YOUR_TUNNEL_ID>
        credentials-file: /root/.cloudflared/<YOUR_TUNNEL_ID>.json

        ingress:
          - hostname: labs.yourdomain.com
            service: http://<Guacamole_LXC_IP>:8080/guacamole/ # Replace with your Guacamole LXC's IP
            originRequest:
              noTLSVerify: true # Use only if Guacamole is HTTP. If HTTPS, set to false.
          - service: http_status:404
        ```
    * Start the tunnel: `cloudflared tunnel run CyberShield-Labs-Tunnel`
    * *(Self-note: Configure this as a systemd service for auto-start on boot).*
5.  **Create DNS Record in Cloudflare:**
    * In your Cloudflare dashboard, navigate to `DNS` -> `Records`.
    * Add a CNAME record: `labs.yourdomain.com` pointing to `<YOUR_TUNNEL_ID>.cfargotunnel.com`. Cloudflare will usually detect this automatically when you create the tunnel.
6.  **Test External Access:** Try accessing `https://labs.yourdomain.com` from an external network. You should see the Guacamole login page.
7.  **Optional: Cloudflare Access:** For enhanced security, configure Cloudflare Access to protect `labs.yourdomain.com` using email PINs, Google SSO, etc.

## Phase 4: Create LXC & KVM Templates

### A. Kali Linux LXC Template

1.  **Create Base Debian LXC:**
    * In Proxmox Web UI, click `Create CT`.
    * **Hostname:** `kali-template-base`
    * **Template:** Debian 12 (Bookworm) standard.
    * **Disk Size:** 20GB.
    * **CPU:** 2 cores.
    * **RAM:** 1GB.
    * **Network:** Connect to `vmbr0` temporarily (for internet access to install tools). Use DHCP.
    * **Features:** Ensure `Nesting` is **NOT** enabled.
    * Start the LXC.
2.  **Configure Kali LXC Base:**
    * SSH into `kali-template-base`.
    * `sudo apt update && sudo apt upgrade -y`
    * `sudo apt install -y sudo openssh-server net-tools iputils-ping`
    * **Create Student User:**
        ```bash
        sudo adduser student
        sudo usermod -aG sudo student
        # Set a default password for the student user for the template, students can change later
        echo "student:password" | sudo chpasswd
        ```
    * **Install Kali Tools (Choose based on resources/needs):**
        * **Minimal Nmap:** `sudo apt install -y nmap`
        * **Recommended Set:** `sudo apt install -y kali-tools-top10 kali-tools-passwords kali-tools-web kali-tools-forensics` (This might be a large download).
        * **Full Kali (Resource Intensive):** `sudo apt install -y kali-linux-full` (Only if you have significant server resources).
    * **Clean Up (Optional but recommended):**
        ```bash
        sudo apt clean
        sudo apt autoremove -y
        sudo rm -rf /var/lib/apt/lists/*
        sudo history -c # Clear bash history
        ```
    * **Shutdown:** `sudo shutdown -h now`
3.  **Convert to Template:**
    * In Proxmox Web UI, select `kali-template-base` LXC.
    * Right-click -> `Convert to Template`. Confirm.

### B. Metasploitable2 KVM VM Template

1.  **Download Metasploitable2:**
    * Get the pre-built Metasploitable2 VM image (e.g., `Metasploitable2-Linux.vmdk` or `.ova` format). You'll typically find this on Offensive Security's website or similar security lab resources.
2.  **Convert Image to QCOW2:**
    * Upload the `.vmdk` (or extract from `.ova`) to your Proxmox host's `/var/lib/vz/template/iso/` directory (or other storage).
    * Convert to QCOW2 format (if not already):
        ```bash
        qm importdisk <VM_ID> <path_to_vmdk> <storage_name>
        # Example: qm importdisk 900 /var/lib/vz/template/iso/Metasploitable2-Linux.vmdk local-lvm
        ```
3.  **Create Metasploitable2 KVM VM:**
    * In Proxmox Web UI, click `Create VM`.
    * **VM ID:** e.g., `900` (for template, then clone from this).
    * **Name:** `metasploitable2-template`
    * **OS:** Select "Do not use any media".
    * **System:** Default options usually fine.
    * **Disks:** Use the imported QCOW2 image as the primary disk.
    * **CPU:** 1-2 cores.
    * **RAM:** 512MB - 1GB.
    * **Network:** Temporarily connect to `vmbr0` to allow initial configuration if needed. Set to DHCP.
    * **Confirm VM Creation:** Do NOT start immediately.
4.  **Attach Converted Disk:**
    * Go to the `metasploitable2-template` VM's `Hardware` tab.
    * Detach the default `hard disk` that Proxmox might have created.
    * Click `Add` -> `Hard Disk`.
    * Select the `Unused Disk` corresponding to the QCOW2 you imported earlier.
    * **Bus/Device:** SCSI (for better performance).
    * **Cache:** Write back (usually good balance).
5.  **Configure Metasploitable2 (if needed):**
    * Start the `metasploitable2-template` VM.
    * Access its console via Proxmox.
    * Default credentials are `msfadmin`/`msfadmin`.
    * Verify network connectivity (it should get an IP from `vmbr0`'s DHCP).
    * Ensure SSH and VNC (or RDP) are running and accessible. `Metasploitable2` typically has these enabled by default.
    * **Shutdown:** `sudo shutdown -h now`
6.  **Convert to Template:**
    * In Proxmox Web UI, select `metasploitable2-template` VM.
    * Right-click -> `Convert to Template`. Confirm.

## Phase 5: Lab Deployment Automation Strategy

This is where "vibe-coding" with AI can really shine, as it involves scripting repetitive tasks.

1.  **Define Lab Structure:** Decide how many Kali LXCs and Metasploitable2 VMs per isolated network (e.g., 1 Kali + 1 Metasploitable2 per student).
2.  **IP Addressing Scheme:** Plan a clear IP addressing scheme for your isolated networks.
    * Example:
        * `vmbr101`: `10.101.0.0/24` (Kali: `10.101.0.10`, Metasploitable2: `10.101.0.20`)
        * `vmbr102`: `10.102.0.0/24` (Kali: `10.102.0.10`, Metasploitable2: `10.102.0.20`)
        * ...and so on.
        * A small `dnsmasq` LXC on each `vmbrX` can handle DHCP for that segment, or you can assign static IPs within the script.
3.  **Proxmox API/CLI Scripting (Bash/Python):**
    * The script will perform the following for each student/lab session:
        * **Clone Kali LXC:** `pct clone <template_id> <new_ct_id> --hostname <new_hostname>`
        * **Clone Metasploitable2 VM:** `qm clone <template_id> <new_vm_id> --name <new_vm_name>`
        * **Assign Network:**
            * For LXC: `pct set <new_ct_id> --net0 name=eth0,bridge=vmbrX,ip=<kali_ip>/24,gw=<dhcp_lxc_ip>` (or use `ip=dhcp`)
            * For VM: `qm set <new_vm_id> --net0 model=virtio,bridge=vmbrX,ip=<metasploitable_ip>/24,gw=<dhcp_lxc_ip>` (or use `ip=dhcp`)
        * **Start Machines:** `pct start <new_ct_id>` and `qm start <new_vm_id>`
        * **DHCP Server (if separate LXC):** If using a dedicated `dnsmasq` LXC for each `vmbrX`, the script would also need to deploy/configure that.
        * **Guacamole Connection Creation:** This is the trickiest part. You'll need to use Guacamole's REST API to programmatically create SSH and VNC/RDP connections for each new Kali LXC and Metasploitable2 VM. This usually involves:
            * Authenticating to Guacamole's API to get an authentication token.
            * Making `POST` requests to create new connection objects, specifying the protocol (SSH, VNC), IP address, port, and credentials.
            * *(Self-note: Research Guacamole API documentation thoroughly for this step).*
4.  **Clean-up Script:** A corresponding script to shut down, destroy LXCs/VMs, and remove Guacamole connections.