#!/bin/bash

# set password authentication on パスワード認証を許可する（ハンズオンを簡単に行うため）
sed -i -e "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

# joushi アカウントが無い場合、joushi アカウントをパスワードと共に設定する
id -u joushi &>/dev/null || (adduser --disabled-password --gecos "" "joushi" && gpasswd -a joushi sudo && echo 'joushi:BZJ5LmFXfbzQPdgE' | chpasswd)

systemctl restart ssh

# TODO: sudoers file で NOPASS にすると sudo したときにパスワードいれなくても済むからハンズオンしやすいという良さがあるかもしれない
