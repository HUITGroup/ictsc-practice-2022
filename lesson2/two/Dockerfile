# # FROM ubuntu:20.04
FROM jrei/systemd-centos:7

ENV HOME /root
WORKDIR /root

# どうしても neofetch を入れたかったマン
RUN curl -o /etc/yum.repos.d/konimex-neofetch-epel-7.repo https://copr.fedorainfracloud.org/coprs/konimex/neofetch/repo/epel-7/konimex-neofetch-epel-7.repo

RUN yum install -y neofetch iproute tcpdump traceroute

RUN echo 'PS1="\u@\[$(tput sgr0)\]\[\033[38;5;9m\]\h\[$(tput sgr0)\]:\w\\$ \[$(tput sgr0)\]"' >> ~/.bashrc
