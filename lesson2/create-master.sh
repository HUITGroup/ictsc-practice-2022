#!/bin/bash

# set password authentication on パスワード認証を許可する（ハンズオンを簡単に行うため）
sed -i -e "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

# kakedashi アカウントが無い場合、kakedashi アカウントをパスワードと共に設定する
id -u kakedashi &>/dev/null || (adduser --disabled-password --gecos "" "kakedashi" && gpasswd -a kakedashi sudo && echo 'kakedashi:BZJ5LmFXfbzQPdgE' | chpasswd)

systemctl restart ssh

# ここ以降はちゃんと動作確認していないのであとで確認します
sudo su kakedashi

# docker のインストール
# docker コマンドがない場合、入れる。（複数回実行しても大丈夫なように）
if ! command -v docker &>/dev/null; then
  echo "docker could not be found"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io
else
  echo "docker already exists."
fi

# docker-compose と ovs のインストール
apt-get install -y docker-compose openvswitch-common openvswitch-switch

# TODO: sudoers file で NOPASS にすると sudo したときにパスワードいれなくても済むからハンズオンしやすいという良さがあるかもしれない → やった。

# 注記：ハンズオンということで、簡単にできるように、セキュリティは万全ではないことを承知のうえで外から直接SSH・パスワード方式にしました。
