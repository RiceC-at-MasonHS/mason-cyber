FROM kalilinux/kali-rolling

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]