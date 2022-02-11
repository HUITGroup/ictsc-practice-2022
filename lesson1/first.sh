#!/bin/bash

echo "initialize start!"

# nginx も入れつつ apache を動かしておく
apt-get -y update
apt-get install -y nginx
systemctl stop nginx
systemctl disable nginx
echo "diabled nginx."
apt-get install -y apache2
systemctl start apache2
echo "started apache2."

# nginx 設定ファイルを壊す
sed -i -e 's/var\/www\/html;/homes\/joushi\/site/' /etc/nginx/sites-available/default

apt-get -y update
apt-get install -y ca-certificates curl gnupg lsb-release

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

apt-get install -y docker-compose

# download kuppa site
mkdir -p site
wget -q -O site/index.html https://gist.githubusercontent.com/takapiro99/7f4a789203b2f8e5dddf70c6551faede/raw/5e6e85e08c30934c5246ffbb9bcfbd826ddaebdd/kuppa-page.html

# 権限を 0 に設定する
chmod 000 site/index.html

# firewall で 22 番以外閉じておく。
ufw disable
ufw -f reset
ufw allow 22
ufw -f enable
ufw reload

# https://patorjk.com/software/taag/#p=display&h=0&v=0&f=Dancing%20Font&t=done!
echo '

  ____       U  ___ u   _   _     U _____ u   _
 |  _"\       \/"_ \/  | \ |"|    \| ___"|/ U|"|u
/| | | |      | | | | <|  \| |>    |  _|"   \| |/
U| |_| |\ .-,_| |_| | U| |\  |u    | |___    |_|
 |____/ u  \_)-\___/   |_| \_|     |_____|   (_)
  |||_          \\     ||   \\,-.  <<   >>   |||_
 (__)_)        (__)    (_")  (_/  (__) (__) (__)_)

'
