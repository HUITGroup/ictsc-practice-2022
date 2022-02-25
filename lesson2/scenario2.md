
## ２つめ

:::info
のまえに、1つ目の後片付けをします
```
$ cd ~/one
$ docker-compose down
$ sudo bash reset.sh
```
:::

:::info
つぎに、2つ目の環境構築！

```
$ cd ~/two
$ docker-compose up

// 別のターミナルから
$ sudo bash set.sh
^^^ sudo bash set.shかも？
```
:::

これが生えます（ぶれてて草）
![](https://i.imgur.com/p7PHzLq.png)

今回は、IPアドレスはあらかじめ設定をしておきました。

S1 は centos、s2はubuntuです。

R1 `show ip route` をすると（linux の `$ ip route` と同じです）色々見れますが、10.4.x.x とかは知らないので困りますね

R1, R2, R3 で経路情報を交換したくなりました。シナリオ1みたいに手動でデフォルトルートを設定してもいいですが、分岐がたくさんできたときに細かくこのアドレスはこっち、このアドレスはこっちって設定するのだるすぎですね

動的に経路交換をしてくれるダイナミックルーティングプロトコルがいくつかありますが、（RIP, OSPF, BGP）今回は簡単なRIPを使います。RIPは、自分の知ってる経路情報を30秒おきにUDPで送りつけるというプロトコルです。

sudo tcpdump でRIPが来るのが見れたらあなたはラッキーです
（tcpdump -i eth22 みたいにインターフェイス指定したらいいかも？）

ダイクストラ法で最適経路を導くOSPFや、重みづけができるBGPと違ってちょっとださい気がしますが、まあやってみましょう

・インターネットで使われているのは、BGP というプロトコルです

※ `conf` で edit mode に入ってから打ってね！
※ 終わったら commit して save して exit してね！

R1 `set protocols rip interface eth11`
R2 `set protocols rip interface eth20`
R2 `set protocols rip interface eth21`
R3 `set protocols rip interface eth31`

それぞれに `set protocols rip redistribute connected` が必要かもしれない

`commit&&save&&exit`
超簡単ですね


例えば R3 で

R3 `show ip route` すると、きちんと `10.1.x.x` の経路情報を知ってることが分かります。やったね！

S1->S2 に ping してみましょう。すぐはできないです確か…

![](https://i.imgur.com/qxkAo7M.png)

---

![](https://i.imgur.com/wz9x55V.png)


あと、S1でneofetch した結果だれかスクショのっけてください（かっこいいので）

![](https://i.imgur.com/HuvrfOa.png)

---

VNC に触れてみようのコーナー

S2 で VNC サーバーが動いています。

手元のVNCクライアントで `自分のIP:5901` に繋いでみましょう。パスワードは `password` です。

ubuntu に繋がったと思います。


（ほぼ何もソフトが入っていないので、CLIからchromiumでも入れてみてください←時間つぶしのつもりで入れました）

ハンズオンは以上です！！！うそです

### NAT編

上司「S1からS2は見えていいけど、S2からS1は見えたらあかんやろ！」

ということで、R1で source NAT(NAPT)をします。
https://docs.vyos.io/en/equuleus/configuration/nat/index.html
R1
```
set nat source rule 100 outbound-interface 'eth11' // 外側はこちらだぜと定義
set nat source rule 100 source address '0.0.0.0/0' ここから出るやつは全部NATする
set nat source rule 100 translation address 'masquerade'
```

すると、S1->R3のping(->s2でもよい) を R3 で tcpdump したときに、あたかも R1 から飛んできたように見える。NAT成功！

明日がんばりましょう

---

番外編 できなかったこと

・いちいち10.x.x.x とか打つのめんどくさいので、DNSをどっかに入れて ping r1 とかしたかった
・OSPFとかBGPのほうがかっこよさそうなのでそっちもやりたかった

---