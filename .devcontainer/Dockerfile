FROM gregewing/windows_on_linux:peru_windows-server-2022-standard-x64-eval

RUN apt-get update && apt-get -y install sudo bash git python3 python-is-python3 curl socat libgit2-1.1 xdotool wget tar net-tools && \
    apt-get -y full-upgrade && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root/
RUN wget -O - https://github.com/novnc/noVNC/archive/v1.5.0.tar.gz | tar -xzv -C /root/ && mv /root/noVNC-1.5.0 /root/novnc && ln -s /root/novnc/vnc_lite.html /root/novnc/index.html && \
    wget -O - https://github.com/novnc/websockify/archive/v0.12.0.tar.gz | tar -xzv -C /root/ && mv /root/websockify-0.12.0 /root/novnc/utils/websockify

COPY Vagrantfile /vagrant/Vagrantfile
COPY startup.sh startup.sh
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV DEBIAN_FRONTEND=noninteractive TERM=xterm-256color MEMORY=4096 CPU=4 DISK_SIZE=50

ENTRYPOINT ["/startup.sh"]
