# Project Overview: Cybersecurity Lab for Chromebook Users

## Project Title
CyberShield Labs: Web-Accessible, Isolated Cybersecurity Training Environment

## Project Goal
To provide high school cybersecurity students with hands-on experience in Linux, network scanning (Nmap), and interacting with vulnerable machines (e.g., Metasploitable2) within secure, isolated virtual environments, all accessible via a web browser from school-issued Chromebooks.

## Problem Statement
School-issued Chromebooks lack native SSH client access, making traditional Linux VM labs challenging. Students need a simplified, web-based interface to interact with virtual machines and containers without complex client-side setup. We also need to ensure network isolation between student lab environments to prevent cross-contamination and maintain security.

## Solution Approach
Leverage Proxmox VE as the virtualization platform to host lightweight Linux Containers (LXC) for student workstations (Kali/Debian) and Kernel-based Virtual Machines (KVM) for vulnerable target systems (Metasploitable2). Access will be provided via a centralized Apache Guacamole server, exposed securely through a Cloudflare Tunnel.

## Key Features
* **Web-based Access:** Students access their lab environments directly through a web browser.
* **Isolated Networks:** Each student or group will have a dedicated, isolated virtual network segment.
* **Rapid Provisioning:** Ability to quickly spin up pre-configured Kali Linux LXCs and Metasploitable2 KVMs from templates.
* **Scalability:** Designed to support a reasonable number of concurrent student labs on a single "extra server."
* **Security:** Multi-layered security with Cloudflare Tunnel, Guacamole authentication, and network isolation within Proxmox.
* **Flexibility:** Support for both specialized Kali Linux environments and basic Debian environments for general Linux practice.

## Target Audience
High school cybersecurity students using school-issued Chromebooks.

## Success Metrics
* All students can successfully access their lab environments via the web interface.
* Students can effectively use Nmap and other tools within their Kali LXCs.
* Students can interact with and practice against vulnerable target machines.
* No network leakage or interference between individual student lab environments.
* Minimal setup and troubleshooting time for teachers and IT staff during class.