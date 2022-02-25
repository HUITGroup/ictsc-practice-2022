# 第 1 回 Web と Linux 編

## 内容

- [座学編](lecture.md)
- [ハンズオン編 ～シナリオ ① ～](scenario1.md)
- [ハンズオン編 ～シナリオ ② ～](scenario2.md)

### ハンズオン環境構築について

GCP の GCE 上に環境を作りました。まずマスターとなるインスタンスを作り、人数分それをコピーしていきました。

マスターインスタンスの作り方

- まず ubuntu 20.04 を一つ用意します。今回は `e2-small` を使いました。
- GCP の vpc のファイアウォールの設定で、全許可のルールを作成し、それを GCE インスタンスに適用させます（AWS でいうところのセキュリティルール）
  - これを忘れていると、ufw でポート開放してもアクセスできないということになります。
- `create-master.sh` を一回だけ実行します。これにより joushi ユーザーが作成されます。
- 次に、`joushi` アカウントでログインできることを確認し、`first.sh` と `second.sh` をホームディレクトリに置きます。
  - あえて参加者に環境構築コードを実行させたのは、"やってる感" を演出したかったからです。

マスターインスタンスを作ったら、その時点でのスナップショットを取得します。次に、GCE の新規作成時にディスクイメージに先ほどのスナップショットを指定することでコピーが作成できます。

`gcloud` コマンドを使いました。例えば以下のコマンドにより、`gce-0` ~ `gce-9` という名前でインスタンスが 10 個できます。（※プロジェクト名とスナップショット名に依ります。VM の新規作成画面を進んでいくと最下部に等価なコマンドが出てくるので、それをコピペしました。）

ネットワークタグで `ictsc-practice` というのを指定していますが、これは GCP でのファイアウォールの設定です。

（powershell）

```
for ($i=0; $i -lt 10; $i++){ gcloud compute instances create "gce-$i" --project=ictsc-practice --zone=asia-northeast1-b --machine-type=e2-small --network-interface="network-tier=PREMIUM,subnet=default" --maintenance-policy=MIGRATE --no-service-account --no-scopes --tags="ictsc-practice,http-server,https-server" --create-disk="auto-delete=yes,boot=yes,device-name=gce-$i,mode=rw,size=10,source-snapshot=projects/ictsc-practice/global/snapshots/snapshot-0211,type=projects/ictsc-practice/zones/asia-northeast1-b/diskTypes/pd-balanced" --reservation-affinity=any }
```
