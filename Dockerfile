FROM ubuntu:latest
RUN apt-get update
ARG S6_OVERLAY_VERSION=3.1.0.1
RUN apt install -y openssh-server nano htop
RUN apt install -y sudo figlet lolcat
ENV DEBIAN_FRONTEND noninteractive
RUN apt install -y ufw net-tools netcat curl apache2
RUN apt install -y inetutils-ping php libapache2-mod-php
RUN apt install -y iproute2 default-jre bc
RUN apt install -y build-essential git
RUN apt install -y wireguard 
RUN apt install -y zsh
RUN apt-get -y install xz-utils
RUN curl -fsSL https://deb.nodesource.com/setup_18.x |sudo -E bash - && \
    sudo apt-get install -y nodejs
RUN sudo -S npm install -g --unsafe-perm node-red
RUN service ssh start
RUN echo 'root:admin' | chpasswd
COPY wireguard /etc/init.d/
#peer variabl
COPY /wg/clients/peer-36/peer-36.conf /etc/wireguard/wg0.conf
RUN echo "clear" >> /etc/bash.bashrc
RUN echo "figlet -t -c youngstorage | lolcat" >> /etc/bash.bashrc
RUN echo "echo ''" >> /etc/bash.bashrc
RUN curl -fsSL https://code-server.dev/install.sh | sh
#Username Variable
RUN adduser anish --gecos "" --disabled-password
RUN echo "anish:anish@321" | sudo chpasswd
RUN usermod -aG sudo anish
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git
COPY .bashrc /home/anish/
COPY .zshrc /home/anish/
COPY setup.sh /
COPY /code-server/login.html /usr/lib/code-server/src/browser/pages/
COPY /code-server/login.css /usr/lib/code-server/src/browser/pages/
COPY /code-server/global.css /usr/lib/code-server/src/browser/pages/
COPY /code-server/logo.png /usr/lib/code-server/src/browser/media/
COPY /code-server/workbench.html /usr/lib/code-server/lib/vscode/out/vs/code/browser/workbench/
COPY /index.html /var/www/html/
COPY /settings.js /home/anish/.node-red/
#Ssh_Peer_variable
COPY /ssh/keys/peer-7/id_rsa.pub /home/anish/.ssh/authorized_keys
RUN chmod +x setup.sh
CMD ["./setup.sh"]
