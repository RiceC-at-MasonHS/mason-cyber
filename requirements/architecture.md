# Architectural Design: CyberShield Labs

## Core Components

1.  **Proxmox VE Host Server:**
    * **Role:** The hypervisor managing all virtualized resources (LXC containers, KVM VMs).
    * **Networking:**
        * `vmbr0`: Management network for Proxmox itself, connected to the school's LAN.
        * `vmbrX` (e.g., `vmbr101`, `vmbr102`...): Multiple isolated virtual bridges, one for each student/group lab. These are *internal-only* and **not** connected to the physical school network.
        * **DHCP/DNS:** Each isolated `vmbrX` will require a DHCP server (e.g., a small LXC running `dnsmasq`) to assign IPs to lab machines within that segment.

2.  **Apache Guacamole Server (LXC or VM):**
    * **Role:** Central web-based access gateway. Translates web browser input into VNC/RDP/SSH sessions to the lab machines.
    * **Placement:** Dedicated LXC container on the Proxmox host, connected to `vmbr0` (management network) to be accessible by the Cloudflare Tunnel.
    * **Configuration:** Configured to create connections to individual student Kali LXCs (via SSH) and Metasploitable2 KVMs (via VNC/RDP).

3.  **Cloudflare Tunnel:**
    * **Role:** Securely exposes the Apache Guacamole web interface to the internet without opening firewall ports.
    * **Component:** `cloudflared` daemon running on the Proxmox host or a small dedicated LXC/VM, connected to `vmbr0`.
    * **Routing:** Directs external traffic from `labs.yourdomain.com` to the internal IP and port of the Guacamole server.

4.  **Student Lab Environments (Per Student/Group):**
    * **Kali Linux LXC Container:**
        * **Role:** Student's primary attack machine for running tools like Nmap.
        * **Base:** Debian LXC template, with Kali tools installed.
        * **Access:** SSH via Apache Guacamole.
        * **Networking:** Connected to its assigned isolated virtual network (`vmbrX`).
    * **Metasploitable2 KVM VM:**
        * **Role:** Deliberately vulnerable target machine for hands-on exploitation practice.
        * **Base:** Imported Metasploitable2 KVM image.
        * **Access:** VNC/RDP via Apache Guacamole.
        * **Networking:** Connected to the *same* isolated virtual network (`vmbrX`) as its paired Kali LXC.

## Network Topology (Logical - Per Student Lab)
[Student Chromebook] --- (Internet/School LAN) --- [Cloudflare Tunnel]
    |
    V
[Apache Guacamole Server] (on vmbr0)
    |
    | (SSH/VNC/RDP connections proxied)
    V
+------------------------------------------+
| Proxmox VE Host                          |
|                                          |
|       +------------------+               |
|       | vmbrX (Isolated) |               |
|       +--------+---------+               |
|                |                         |
|      +---------+---------+               |
|      |                   |               |
|  [Kali LXC]  <--->  [Metasploitable2 VM] |
|  (10.X.Y.10)        (10.X.Y.20)          |
|                                          |
+------------------------------------------+

## Data Flow
1.  **Student Access:** Student navigates browser to `labs.yourdomain.com`.
2.  **Cloudflare Tunnel:** Cloudflare intercepts the request, and the `cloudflared` daemon on the Proxmox host establishes a secure tunnel to Cloudflare. The request is then forwarded internally to the Apache Guacamole server.
3.  **Apache Guacamole:** Student authenticates. Guacamole presents available lab connections.
4.  **Session Proxy:** When a student selects a Kali LXC or Metasploitable2 VM connection, Guacamole establishes an SSH (for Kali) or VNC/RDP (for Metasploitable2) session to the target machine's IP address on its respective isolated network.
5.  **Interaction:** Guacamole streams the session (terminal output or graphical desktop) back to the student's browser. Keyboard/mouse input from the student's browser is sent back through Guacamole to the target machine.
6.  **Lab Isolation:** All communication between the Kali LXC and Metasploitable2 VM occurs *only* within their dedicated `vmbrX` isolated network segment, never touching the school LAN or other student networks.

## Security Considerations

* **Cloudflare Access:** Consider enabling Cloudflare Access for an additional layer of authentication (e.g., Google Workspace SSO) before Guacamole.
* **Guacamole Authentication:** Use strong authentication for Guacamole (e.g., database-backed users with strong passwords).
* **Least Privilege:** Students will use non-root accounts in their LXCs.
* **Proxmox Firewall:** Configure Proxmox host firewall rules to strictly enforce network isolation between `vmbrX` segments.
* **Regular Updates:** Keep Proxmox, Guacamole, and all guest OSes updated.
* **Snapshotting:** Utilize Proxmox snapshots to easily revert lab environments to a clean state.