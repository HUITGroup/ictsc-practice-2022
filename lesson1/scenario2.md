# ハンズオン編 シナリオ ②

### シナリオ ②

> 上司「お、修正ありがとう。今度はバックエンドも作りたくなったわ。docker-compose で組み立ててみたんだけど、なんか動かんわ。見てくれん？」
> 上司「あ、new-site フォルダーに置いてあるから。」
> 上司「ガッハッハ…」
> （上司帰宅）

---

`$ sudo bash ./second.sh`
を打ち込むと、シナリオ ② の環境構築が完了します。  
シナリオ ② の環境をリセットしたい場合も、このコマンドでリセットできます。

---

現状：docker-compose の立ち上げから  
目標：5000 番ポートで、外側から見れるようにする。

まずは、`$ cd new-site` からの `$ sudo docker-compose up`

一つターミナルが docker に取られるので、もう一枠 SSH するのがおすすめ。

#### 基本編

- `http://<サーバーのIP>:5000` をブラウザで開いたら正しく結果が返ってくることを目指す。
  - `$ sudo docker-compose up` の結果を見つめる
  - docker-compose.yml を編集して動くようにしよう（一か所だけ。）
  - ファイアウォールも開放する。すると外から見れるようになる。
  - `http://<サーバーのIP>:5000`

ちなみに正解がこちらです（分かりづらくてごめん！）

```
{"images":["https://4.bp.blogspot.com/-a7WEvuIz_-4/W1vhClOop5I/AAAAAAABNtY/FjTJQ-3P41AFPX8QSCZXLU05YgKc8xntACLcBGAs/s800/character_earth_chikyu.png%22,%22https://1.bp.blogspot.com/-0S46QU6KoCM/WxvKQsHCcnI/AAAAAAABMn4/QEjMZyeeJVIrGAmauqC5F887L--c8hzpACLcBGAs/s800/monogatari_momotarou_solo.png%22]%7D
```

#### 応用編

<!-- https://takapiro99.github.io/sandbox/ictsc-practice-2  -->

別部署の人が作ってくれた完璧なフロントエンド ↑ に対して、バックエンドが正しく動いていないようです。（[フロントのソースはこちら](https://raw.githubusercontent.com/takapiro99/takapiro99.github.io/main/sandbox/ictsc-practice-2.html)）← のそーすを手元にダウンロード(又はコピペ)し、ローカルでサーブする必要があります。（こちらの不手際ですまぬ！）`$ npx http-server` や VSCode の live-server を使ってください。 **手元の HTML は編集してはいけません。編集対象は app/以下です。**

- allow-origins に追加すべきオリジンは？
- allow-methods もいじる。
- ２つの機能の両方が正しく動けばゴール。
<!--   ほんとうはOPTIONSの制御を入れたかったが、fastapiが優秀すぎた  -  -->

<br/>
<br/>

#### 解説

- 基本編
  - yml ファイルは、インデントが大きなカギを握っています。今回は、5 行目のインデントが 1 マスだけずれているというミスでした。
  - ファイアウォールはシナリオ ① と同様です。5000 番を開けてください。
- 応用編
  - CORS(こるす)(Cross-Origin Resource Sharing)というセキュリティに関する設定です。origin は、プロトコル・ドメイン・ポートの三点セットです。HTML のファイルが配信されているオリジンと、アクセスするサーバーのオリジンが異なる場合、デフォルトではサーバーでアクセスを断ります。
  - レスポンスヘッダーに、アクセスを許すオリジンを記載することができるので、そこに手元の HTML のオリジンを入れましょう。例えば `http://localhost:5000` とか、`http://127.0.0.1:5000`とか。
  - ここまでやると、もっと見る機能が使えるようになります。
  - いいね機能は、PUT リクエストを使っています。CORS はリクエストメソッド別に制限をかけることができ、allow-methods みたいなところに PUT を追記すれば OK でした。（GET はデフォで通してくれるのは多分仕様）
  - ここで、[単純リクエスト](https://developer.mozilla.org/ja/docs/Web/HTTP/CORS#%E5%8D%98%E7%B4%94%E3%83%AA%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88) 以外のリクエストでは、OPTIONS メソッドのリクエストがプリフライトとして飛ばされることが知られています。そこに気づけるか…！みたいなこともやりたかったのですが、fastapi がうまく吸収してくれていたみたいで、考えなくても良くなってました。
