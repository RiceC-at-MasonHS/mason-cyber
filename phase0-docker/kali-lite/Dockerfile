# kali-lite/Dockerfile - Optimized for limited RAM (Dell Latitude 5340)
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
    dnsutils \
    telnet \
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
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config

# Copy setup script
COPY setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Create useful aliases
RUN echo 'alias ll="ls -la"' >> /home/student/.bashrc && \
    echo 'alias scan="nmap -sS"' >> /home/student/.bashrc && \
    echo 'alias vulnscan="nikto -h"' >> /home/student/.bashrc && \
    echo 'alias portscan="nmap -p-"' >> /home/student/.bashrc && \
    echo 'alias quickscan="nmap -T4 -F"' >> /home/student/.bashrc && \
    chown student:student /home/student/.bashrc

# Create a simple cybersecurity toolkit script
RUN echo '#!/bin/bash' > /home/student/cyber-toolkit.sh && \
    echo 'echo "=== CyberShield Labs Toolkit ==="' >> /home/student/cyber-toolkit.sh && \
    echo 'echo "1. scan <ip>     - Basic nmap scan"' >> /home/student/cyber-toolkit.sh && \
    echo 'echo "2. vulnscan <ip> - Web vulnerability scan"' >> /home/student/cyber-toolkit.sh && \
    echo 'echo "3. portscan <ip> - Full port scan"' >> /home/student/cyber-toolkit.sh && \
    echo 'echo "4. quickscan <ip>- Fast scan"' >> /home/student/cyber-toolkit.sh && \
    echo 'echo "Target IP: 10.X.0.20 (where X is your lab number)"' >> /home/student/cyber-toolkit.sh && \
    chmod +x /home/student/cyber-toolkit.sh && \
    chown student:student /home/student/cyber-toolkit.sh

EXPOSE 22

CMD ["/usr/local/bin/setup.sh"]
