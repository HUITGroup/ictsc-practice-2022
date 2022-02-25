# ハンズオン 1

VSCode の remote SSH がおすすめです

はじめる前に：VNC クライアントを入れておきましょう
MAC の人は標準で入ってるらしい
windows の人はこれとかダウンロードしておきましょう
https://www.realvnc.com/en/connect/download/viewer/
（他にも種類がいくつかあるっぽい）
https://www.google.com/search?q=vnc+client

---

基本的なコマンド

#### サーバー

ふつうの linux
iproute2 っていうコマンド群

#### ルーター

VyOS ← linux ベースのやつ

https://docs.vyos.io/en/equuleus/

- conf と打つと edit mode に入れます
- commit
- save
- といれると保存されて
- exit で edit mode から抜けれます
- commit&&save&&exit

---

### シナリオ１

:::info
シナリオ構築します

```
$ cd one
$ docker-compose up
```

こんなのが出るまで待ちます
![](https://i.imgur.com/fHzYv4e.png)

```
// 別ターミナルで
$ sudo bash set.sh
```

:::

そしたら以下ができあがります。

```
s1
|eth11
|
|eth10
r1
|eth12
|
|eth13
s2
```

サーバーに入ってみましょう

```
$ attach s1
```

インターフェイスを見てみましょう
77 と 78 はおばけです、ごめんなさい
@S1

```
$ ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 42:01:0a:92:00:33 brd ff:ff:ff:ff:ff:ff
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default
    link/ether 02:42:60:93:10:32 brd ff:ff:ff:ff:ff:ff
77: eth1@f9a6abd0f8114_l: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether ea:5c:76:09:33:5a brd ff:ff:ff:ff:ff:ff
78: f9a6abd0f8114_l@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 06:e8:e0:81:b7:c5 brd ff:ff:ff:ff:ff:ff
```

ip link set eth0 down からの up やってみる？

インターフェイスは存在しますが、IP アドレスが振られていません
これでは通信ができないので、手動で設定してみましょう

IP アドレスを静的に設定してみましょう
:::warning
以下のように振ります

```
s1
|eth11 192.168.1.2/24
|
|eth10 192.168.1.1/24
r1
|eth12 192.168.2.1/24
|
|eth13 192.168.2.2/24
s2
```

:::

---

S1

```
$ ip addr add 192.168.1.2/24 dev eth11
$ ip a で確認
```

R1

```
$ conf
// edit mode に入る
$ set interfaces ethernet eth10 address 192.168.1.1/24
$ set interfaces ethernet eth12 address 192.168.2.1/24
$ commit
$ save
$ exit
// edit mode から抜ける
$ show int で確認
```

S2

```
$ ip addr add 192.168.2.2/24 dev eth13
$ ip a で確認
```

---

できましたね。ここで
S1->R1 を確認してみましょう

S1 `$ ping 192.168.1.1` はできますね。ですが、
S1 `$ ping 192.168.2.1` はできません。同じルーターなのになぜ。。。？

S1 で`ip route`を見てみましょう
S1

```
$ ip route

// 192.168.1.0/24 dev eth11 proto kernel scope link src 192.168.1.2
```

`192.168.1.0/24` 以外の行き先を知らないので、行けなかったんだということが分かった。

S1 にデフォルトルートを設定します

```
$ ip route add default via 192.168.1.1
```

route は default で 192.168.1.1 さんに聞こうねというやつ

そしたら、192.168.2.1 にもアクセスできた。じゃあ S1->S2 は？
S1 `$ ping 192.168.2.2` 返ってこなくて草
各地点で `tcpdump` してみましょう。
R1 `$ sudo tcpdump` した状態で、S1 `$ ping 192.168.2.2`。来てますね
次は
S2 `$ tcpdump` した状態で、S1 `$ ping 192.168.2.2`。来てますね。到達してるけど、帰り方が分からなかったらしい。

S2 にもデフォルトルートを入れてあげます。
S2 `ip route add default via 192.168.2.1`

疎通できた！ :tada:

---

次は DHCP できるかな？
https://docs.vyos.io/en/equuleus/configuration/service/dhcp-server.html

まず一旦消します
S1 `ip addr flush dev eth11`
S2 `ip addr flush dev eth13`

R1

```
show dhcp server statistics
```

ないので作ってみる

R1

```
conf
// edit mode に入る
set service dhcp-server shared-network-name LAN1 subnet 192.168.1.0/24 default-router 192.168.1.1
set service dhcp-server shared-network-name LAN1 subnet 192.168.1.0/24 range 0 start 192.168.1.10
set service dhcp-server shared-network-name LAN1 subnet 192.168.1.0/24 range 0 stop 192.168.1.200
commit
save
exit
// ぬける
restart dhcp server
show dhcp server statistics で確認
```

S1 のほうで dhcp を待ちましょう

```
$ dhclient
```

`$ ip a などして確認してください。`

したら得られたね！
