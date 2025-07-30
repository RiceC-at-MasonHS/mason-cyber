# Troubleshooting & FAQ: CyberShield Labs

This document provides common issues and their resolutions for the CyberShield Labs environment.

## General Connectivity Issues

* **"Unable to connect to Guacamole" (via labs.yourdomain.com):**
    * **Check Cloudflare Tunnel:**
        * Is the `cloudflared` daemon running on your Proxmox host? `sudo systemctl status cloudflared`
        * Is the Cloudflare Tunnel configured correctly in your Cloudflare dashboard (DNS record pointing to the tunnel)?
        * Check `cloudflared` logs for errors.
    * **Check Guacamole Server:**
        * Is the Guacamole LXC running in Proxmox?
        * Is Tomcat running inside the Guacamole LXC? `sudo systemctl status tomcat9`
        * Is `guacd` running inside the Guacamole LXC? `sudo systemctl status guacd`
        * Can you access Guacamole directly via its internal IP (`http://<Guacamole_LXC_IP>:8080/guacamole/`) from your admin workstation? If not, troubleshoot Guacamole installation.
        * Check Guacamole logs (`/var/log/tomcat9/catalina.out` or similar).

* **"Guacamole login page loads, but connections fail/are missing":**
    * **Guacamole Database:** Ensure your Guacamole database is configured correctly and reachable from the Guacamole LXC. Check `guacamole.properties` and database logs.
    * **Guacamole Connections:** Verify that the connections for student LXCs/VMs are correctly configured in Guacamole's administration interface (if you're not automating it, or check your automation script's output). Double-check IP addresses, ports, and credentials.

## Student Lab Specific Issues

* **"Cannot connect to Kali LXC via Guacamole SSH":**
    * **LXC Running:** Is the student's Kali LXC running in Proxmox?
    * **IP Address:** Does the Kali LXC have an IP address? Check its console (`ip a`) or Proxmox summary. Is it on the correct isolated `vmbrX` network?
    * **SSH Server:** Is `openssh-server` running inside the Kali LXC? `sudo systemctl status ssh`
    * **Firewall:** Is the Kali LXC's firewall (if enabled) blocking SSH? Or the Proxmox host firewall blocking traffic to the LXC?
    * **Credentials:** Are the SSH username and password configured in Guacamole correct for the student's LXC?

* **"Cannot connect to Metasploitable2 VM via Guacamole VNC/RDP":**
    * **VM Running:** Is the Metasploitable2 VM running in Proxmox?
    * **IP Address:** Does the VM have an IP address on the correct isolated `vmbrX` network?
    * **VNC/RDP Service:** Is the VNC/RDP service running on the Metasploitable2 VM? (Metasploitable2 usually has VNC on by default, port 5900).
    * **Firewall:** Similar to Kali LXC, check for firewalls on the VM or Proxmox host.
    * **Guacamole Connection:** Verify the VNC/RDP port and password (if any) in Guacamole.

* **"Kali LXC and Metasploitable2 VM cannot communicate with each other (ping fails)":**
    * **Same Network:** Are both the Kali LXC and Metasploitable2 VM assigned to the *exact same* isolated `vmbrX` network bridge in Proxmox? Check their hardware network settings.
    * **IP Addressing:** Do they have IP addresses within the same subnet on that `vmbrX`?
    * **DHCP/Static IPs:** If using DHCP, is your `dnsmasq` LXC running and configured correctly on `vmbrX`? If static, double-check the manual IP configurations.
    * **Firewall on VMs/LXCs:** Are the internal firewalls (e.g., `ufw` on Kali) blocking traffic? Temporarily disable for testing.
    * **Proxmox Host Firewall:** Ensure Proxmox's firewall isn't inadvertently blocking traffic *between* machines on the same `vmbrX`. By default, Proxmox bridges allow traffic, but custom rules could interfere.

* **"Nmap doesn't work or gives unexpected results":**
    * **Target Reachability:** Can the Kali LXC ping the Metasploitable2 VM's IP address?
    * **Firewall:** Double-check internal firewalls on both Kali and Metasploitable2.
    * **Nmap Syntax:** Verify the Nmap command syntax (common student error).
    * **Network Misconfiguration:** Re-check the isolated network setup as described above.

## Proxmox Specific Issues

* **LXC/VM Fails to Start:**
    * **Resources:** Check CPU, RAM, and disk space availability on the Proxmox host.
    * **Disk Images:** Ensure disk images are not corrupted or missing.
    * **Network Bridge:** If you assigned a network interface, ensure the `vmbrX` exists and is active.
* **"Cannot convert LXC/VM to template":**
    * Ensure the LXC/VM is shut down before attempting conversion.
* **Performance Issues (Slowness):**
    * **Server Hardware:** Check physical server CPU utilization, RAM usage, and disk I/O.
    * **Proxmox Resource Allocation:** Adjust CPU cores and RAM assigned to individual LXCs/VMs. LXCs are more efficient, so prioritize them for student machines.
    * **Storage:** Ensure you are using SSDs for optimal performance.

## Security Reminders

* **Never connect isolated lab networks (`vmbrX`) to your main school LAN.**
* **Regularly update** Proxmox, Guacamole, and all guest operating systems.
* **Rotate Guacamole passwords** and change default credentials on templates.
* **Monitor resource usage** to prevent denial-of-service or performance degradation.