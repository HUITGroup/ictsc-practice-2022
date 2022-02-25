# FROM ubuntu:20.04
FROM jrei/systemd-ubuntu

ENV HOME /root
WORKDIR /root

RUN apt-get update && \
    apt-get install -y curl iputils-ping iproute2 neofetch htop tcpdump tshark nano traceroute

# install dhclient
RUN apt-get install -y isc-dhcp-common isc-dhcp-client

# PS1 に色をつけてみました（赤）
RUN echo 'PS1="\u@\[$(tput sgr0)\]\[\033[38;5;9m\]\h\[$(tput sgr0)\]:\w\\$ \[$(tput sgr0)\]"' >> ~/.bashrc
