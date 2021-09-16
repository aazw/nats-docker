## クラスター概要

### cluster 1

* ちゃんと動く設定
* 5台構成のクラスター
* 全台にgateway設定をしている
  * nats-server-1、2、3、4、5はgateway
* cluster 2と接続

### cluster 2

* ちゃんと動く設定
* 5台構成のクラスター
* うち3台にgateway設定をしている
  * nats-server-1、2、3はgateway
  * nats-server-4、5はgatewayではない
* cluster 1と接続

### cluster 3

* 一応動きはする設定
* あくまでも、ある設定に対する動作検証用
* gateway設定を複数記述した場合どうなるかを検証

### cluster 4

* 一応動きはする設定
* あくまでも、ある設定に対する動作検証用
* gateway.gatewaysに自身に対するルート情報を記述しなかった場合どうなるかを検証

### Non Clustering

* 一応動きはする設定
* あくまでも、ある設定に対する動作検証用
* cluster設定とgateway設定はセットなものである雰囲気があったが、cluster設定をせず、gateway設定のみをした場合どうなるかを検証

## 設定検証

```conf

...

# clusterブロック
cluster {
  name: cluster-1

  port: 6222

  authorization {
    user: ruser
    password: T0pS3cr3t
    timeout: 2
  }

  routes = [
    nats://ruser:T0pS3cr3t@cluster-1-nats-server-2:6222
    nats://ruser:T0pS3cr3t@cluster-1-nats-server-3:6222
  ]

  advertise: cluster-1-nats-server-1:6222
}

# gateweyブロック
gateway {
    name: cluster-1 # cluster設定がある場合は、cluster.nameと同じ名前にしなければならない
    listen: 0.0.0.0:7222

    # ここに記載のgatewayに接続しに行く。また、ここに記載の情報をgossipする。
    # つまり、ここに自身への情報(下例でcluste-1)がなければ、他のgateway(cluster-2など)から接続されてくることはない。
    gateways: [ 
        {name: "cluster-1", urls: ["nats://cluster-1-nats-server-1:7222"]}, # 他gatewayから接続してもらうため、自分の情報を意図的に記載している
        {name: "cluster-2", urls: ["nats://cluster-2-nats-server-1:7222"]}
    ]

    advertise: cluster-1-nats-server-1:7222
}
```

#### gateway設定について

* gateway設定はcluster設定がなくても設定できる
* cluster設定がある場合は、cluster.nameとgateway.nameは同じ名前でなければならない
  * 異なる場合、`nats-server: cluster name conflicts between cluster and gateway definitions`というエラーが出てプロセスが終了する
* gateway設定は唯一つでなければならない
  * 複数個のgatewayブロックを書くことはできる(NATSはエラーを吐かない)
  * 最後のgatewayブロックが利用される
  * NATSサーバ1つにつき、gatewayはただ1つ
  * 1つのNATSサーバが複数のgatewayとして動くことはできない

#### gatewayの振る舞い、動きについて

* ゲートウェイ同士が接続する
* gateway記述がないノードはgatewayとしては振る舞わない
* gatewaysに記載された各ゲートウェイに、各gatewayノードあたり1本のデータ送出用コネクションを接続しに行く
* gatewayブロック設定そのものはあるが、その設定の中のgateway.gatewaysのurlに記述がないノードは、同じクラスタでurl記述のあるノードを経由したgossipにより他クラスタのgatewayに発見される
  * gateway.gateways.\*.urlsはclusterのgatewayに対する、他クラスタからアクセスするためのエントリポイントであると言える
  * エントリポイントにアクセスしたあとは、gossip等でエントリポイント記載以外のすべてのgatewayの情報が共有される
  * 当然、そもそもgatewayでないノードの情報は共有されない
* gossipにて見つかったノードにも、データ送出用コネクションを接続しに行く
* データを送ってもらう用の受信向け接続、いわゆるインバウンド接続は自発的には作らない。あくまでも相手方のデータ送信用コネクションとして確立される。

### コネクション数

https://docs.nats.io/nats-server/configuration/gateways

> For those mathematically inclined, cluster connections are N(N-1)/2 where N is the number of nodes in the cluster. On gateway configurations, outbound connections are the summation of Ni(M-1) where Ni is the number of nodes in a gateway i, and M is the total number of gateways. Inbound connections are the summation of U-Ni where U is the sum of all gateway nodes in all gateways, and N is the number of nodes in a gateway i. It works out that both inbound and outbound connection counts are the same.

#### 定義

* N: クラスター内のノードの数
* Ni: あるゲートウェイにおけるノード数
  * ゲートウェイを構成するノード数
  * Niはゲートウェイiのノード数Nの意味
* M: ゲートウェイの総数
  * ゲートウェイ設定の数
* U: すべてのゲートウェイの、すべてのゲートウェイノードの総数
  * ゲートウェイ設定における各ノードの総数

#### コネクション数

* クラスター接続: N*(N-1)/2
* ゲートウェイ構成:
  * アウトバウンド接続 Σi Ni*(M-1)
  * インバウンド接続: Σi (U-Ni)
* アウトバウンドは各ノードから各クラスターに1つ出る
* インバウンドはクラスター内で1つ

#### 結論

* ゲートウェイ接続の数=アウトバウンドの数+インバウンドの数、**ではない**。
* ゲートウェイ接続の数=アウトバウンドの数=インバウンドの数
* アウトバウンド接続は、他方から見ればインバウンド接続なのだから
