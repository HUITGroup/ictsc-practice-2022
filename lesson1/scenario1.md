# ハンズオン編 ①

ハンズオンの目標：とりあえず色々さわる。

GCP 上に演習環境を作成しました。一人一つ？割り当てる

---

まず、配られた IP アドレスで ssh をしてログインします。
もしくは、VSCode 拡張の remote SSH という機能を使ってもよいです

`$ ssh joushi@xxx.xxx.xxx.xxx`
パスワードを聞かれるので、入力します。

**ログイン後、一回だけ次のコマンドを打ちこんでください。**
`$ sudo bash ./init.sh`

（ちなみに、二回以上実行しても大丈夫）  
少し待って、done と出たら環境構築完了です。

---

さて、あなたはとある会社の社員です。

### シナリオ ①

> 上司「nginx ってやつで色々設定してみたけど、どうも見れないんだよ。なあ君、残りの設定やっといてくれないか？ガッハッハ…。あ、配信するファイルは `~/site/` に置いてあるぞ。ログイン情報はこれだから、あとはよろしくな」
> （上司帰宅）

現状：手元からもサーバー自身からも web ページが見れない。
目標：手元からページにアクセスでき、完全に見ることができる。

---

**【キーワード】**

**デーモン**：常駐プログラムのこと。`systemd` が管理していて、`systmectl` コマンドで操作する。`$ systemctl start` で起動、`$ systemctl status` で状態確認など。
**ファイアウォール**：サーバーを不正アクセスやサイバー攻撃などから守るために使われるセキュリティ機能。ubuntu では、`ufw` コマンドで操作する。`$ ufw status` で確認可能。ポートやプロトコル、IP アドレス単位で制御できる。
**権限**：ファイルに対する read/write/execute の権限を rwx で、特権ユーザー、グループの人、自分の順番で表される。`$ ls -l`（ubuntu では`$ ll` でいける）で見ることができ、先頭の d はディレクトリを表す。権限を変えたければ、`$ chmod 666 app.py` などとする。（`666` になる理由はぐぐるか聞いてね！）

```
drwxr-xr-x  2 takapiro takapiro 4096 Sep 15 23:59 templates/
-rw-r--r--  1 takapiro takapiro    0 Sep 15 23:58 app.py
```

**エディタ**：ファイルを編集するときに使うやつです。ターミナルはマウスや VSCode は使えないので、nano(簡単) や vim といったエディタを使ってください。操作は周りの人に聞いてみましょう。もしくは、VSCode 拡張 の remote SSH を使うのもおすすめです。

---

ip アドレスをブラウザに直打ちして、あれれ～ページが見れないぞ～（という茶番をやる）
原因を探り、直すため、SSH しましょう。

#### 基本編

1. nginx 起動してる？ `$ sudo systemctl status nginx` してないね
2. nginx 起動してみるか `$ sudo systemctl start nginx` けど動かない
3. `$ sudo systemctl status nginx` や `$ sudo journalctl -u nginx` 又は `$ sudo tail /var/log/nginx/error.log` などで状況を掴む。

- `$ grep "root /" -r /etc/nginx/` で root の記述を探す
- どうやら conf ファイルに誤りがあるらしい。
- `$ sudo nano /etc/nginx/nginx.conf`
- セミコロンを追加。
- nginx -t で設定ファイルの文法確認。

また起動してみるも、まだ動かない。

1. `$ sudo lsof -i:80` で犯人を探る。
2. 誰が犯人でしたか？systemctl で止めましょう。

- apache2 が動いていました。
- `$ sudo systemctl stop apache2` 止めます
- `$ sudo systemctl disable apache2` 再起動で自動実行を止める

<br/>

1. `$ sudo systemctl start nginx` スタート！
2. あれ、まだ動かない。けどエラー内容が変わったみたい。
3. `$ grep "root /" -r /etc/nginx/` で root の記述を探す(再び)
4. 状況を掴んで修正しましょう。
5. オッケーだったら次。`$ sudo systemctl start nginx`
6. `$ sudo systemctl status nginx` で正常起動できてるっぽいも、サイト見れない :cry:
7. `$ curl localhost` したら見れているので、ファイアウォールを疑う。
8. `$ sudo ufw status` で、22 番しか開いていないことが分かる。
9. 80 番を追加する。`$ sudo ufw allow 80`
10. やっとなにかが見れた！

#### 中級編

1. not found ということは、配信場所が間違っているということ。`$ grep "root /" -r /etc/nginx/` で root の記述を探す
2. nginx.conf の root をまた見にいっていじってみよう。
3. `$ sudo systemctl restart nginx` 設定ファイルいじったら、リスタートしてね

- ホームディレクトリは `/homes/` ではなく`/home/` ですよね！変更して保存。再読み込みする。`$ sudo systemctl restart nginx`
  <br/>

4. ちょっと表示変わった。エラーっぽいのでエラーログを見ましょう `$ tail /var/log/nginx/error.log`

- `$ ll` などで権限を見ると、無の権限だった。`$ sudo chmod 666 index.html` で read 権限をつける。

5. やっとページっぽいものが見れた！でも完全ではないかも。

#### 応用編

画像が表示されない問題を直してください。
ソースをいじってください。セキュリティは考慮せず、なにがなんでも見れたら OK とします。

---

**解説まとめ**

- 基本編
  - nginx の設定ファイルに不備があり、正しく起動できなかった。原因場所を突き止め、直す。
  - apache2 が 80 番ポートを使用しており、正しく起動できなかった。apache2 を止める。
  - ファイアウォールで 80 番ポートがふさがれていた。それを開放する。
- 中級編
  - root の設定がうまくできておらず、せっかくの上司のファイルが配信されず not found となっていた。linux で、（各ユーザーの）ホームディレクトリは `/home/` にあります。`/homes/` とタイポしていたようです。
  - 肝心のファイルの権限が 000 になっていたので、適切な権限（644?あとで確認）に変更する。
- 応用編
  - Content-Security-Policy によって、同一オリジン以外のリソースが使えなくなっていました。このメタタグを消す。（ドメインがある場合はそれを入れるも可）。meta タグの `http-equiv` って HTTP レスポンスのヘッダーと同じ意味だそうですよ、面白いですね。ちなみに、これを無効にする chrome 拡張があります。意味なくて草
