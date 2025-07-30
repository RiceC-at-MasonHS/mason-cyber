# vulnerable-lite/Dockerfile - Very lightweight vulnerable target
FROM ubuntu:20.04

# Install minimal vulnerable services
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server \
    apache2 \
    telnetd \
    vsftpd \
    netcat \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create vulnerable user accounts
RUN useradd -m -s /bin/bash admin && \
    echo "admin:admin" | chpasswd && \
    useradd -m -s /bin/bash test && \
    echo "test:test" | chpasswd && \
    useradd -m -s /bin/bash guest && \
    echo "guest:guest" | chpasswd

# Configure vulnerable SSH (for demonstration only!)
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config && \
    echo 'Port 22' >> /etc/ssh/sshd_config

# Configure vulnerable FTP
RUN echo 'anonymous_enable=YES' >> /etc/vsftpd.conf && \
    echo 'anon_upload_enable=YES' >> /etc/vsftpd.conf && \
    echo 'write_enable=YES' >> /etc/vsftpd.conf && \
    echo 'local_enable=YES' >> /etc/vsftpd.conf

# Create vulnerable web content
RUN echo '<html><body style="font-family: Arial, sans-serif;">' > /var/www/html/index.html && \
    echo '<h1 style="color: red;">🎯 Vulnerable Practice Server</h1>' >> /var/www/html/index.html && \
    echo '<p><strong>This is a practice target for cybersecurity learning.</strong></p>' >> /var/www/html/index.html && \
    echo '<h2>Available Services:</h2>' >> /var/www/html/index.html && \
    echo '<ul>' >> /var/www/html/index.html && \
    echo '<li>SSH (port 22) - Try admin:admin, test:test, guest:guest</li>' >> /var/www/html/index.html && \
    echo '<li>FTP (port 21) - Anonymous login enabled</li>' >> /var/www/html/index.html && \
    echo '<li>Web (port 80) - You are here!</li>' >> /var/www/html/index.html && \
    echo '<li>Telnet (port 23) - Try the user accounts above</li>' >> /var/www/html/index.html && \
    echo '</ul>' >> /var/www/html/index.html && \
    echo '<h2>Practice Exercises:</h2>' >> /var/www/html/index.html && \
    echo '<ol>' >> /var/www/html/index.html && \
    echo '<li>Port scan this server</li>' >> /var/www/html/index.html && \
    echo '<li>Try to login via SSH with weak passwords</li>' >> /var/www/html/index.html && \
    echo '<li>Connect to FTP anonymously</li>' >> /var/www/html/index.html && \
    echo '<li>Check for web vulnerabilities</li>' >> /var/www/html/index.html && \
    echo '</ol>' >> /var/www/html/index.html && \
    echo '<p><em>Remember: This is for educational purposes only!</em></p>' >> /var/www/html/index.html && \
    echo '</body></html>' >> /var/www/html/index.html

# Create additional vulnerable pages
RUN echo '<html><body><h2>Server Information</h2><pre>' > /var/www/html/info.html && \
    echo 'Operating System: Ubuntu 20.04' >> /var/www/html/info.html && \
    echo 'Web Server: Apache 2.4' >> /var/www/html/info.html && \
    echo 'Available Users: admin:admin, test:test, guest:guest' >> /var/www/html/info.html && \
    echo 'Services: SSH, FTP, HTTP, Telnet' >> /var/www/html/info.html && \
    echo 'Security Level: INTENTIONALLY VULNERABLE' >> /var/www/html/info.html && \
    echo '</pre></body></html>' >> /var/www/html/info.html

# Create a "secret" directory (for directory brute-forcing practice)
RUN mkdir /var/www/html/admin && \
    echo '<html><body><h2>Admin Panel</h2><p>Congratulations! You found the hidden admin directory.</p></body></html>' > /var/www/html/admin/index.html

RUN mkdir /var/www/html/backup && \
    echo 'username=admin' > /var/www/html/backup/config.txt && \
    echo 'password=secret123' >> /var/www/html/backup/config.txt

# Set weak file permissions (educational purposes only!)
RUN chmod 755 /var/www/html/backup && \
    chmod 644 /var/www/html/backup/config.txt

EXPOSE 21 22 23 80

CMD service ssh start && \
    service vsftpd start && \
    service apache2 start && \
    /usr/sbin/in.telnetd -L /bin/bash & \
    tail -f /dev/null
