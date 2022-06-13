# ssh-config-manager

## 概要

- SSHクライアント設定ファイル(.ssh/config)の管理を容易にします

## 本方式を採用するメリット

- 本方式を採用することで、以下のメリットがあります
  - .ssh/config肥大化によるメンテナンスコストを最小限にできます
  - メンバーへの展開が容易になります
  - 展開範囲の指定が可能なため、メンバー毎に適切な展開範囲で提供できます

## 本管理方式の特徴

### 管理面

- SSHサーバはconfig.dディレクトリ配下で一元管理します
- サービス単位・デプロイメント環境単位でSSHサーバを管理します
- 1ファイル1サーバで管理します

### 運用面
- 本リポジトリに含まれれるシェルスクリプトを実行することでリポジトリ内にconfigファイルが生成されます
- 生成されたconfigファイルを使ってSSHクライアントに接続できます

## ディレクトリ構成

```
.
├── README.md
├── config
├── config.d
│   ├── private
│   ├── service1
│   │   ├── development
│   │   │   ├── service1-development-db-01
│   │   │   └── service1-development-web-01
│   │   ├── production
│   │   │   ├── service1-production-db-01
│   │   │   └── service1-production-web-01
│   │   ├── staging
│   │   │   ├── service1-staging-db-01
│   │   │   └── service1-staging-web-01
│   │   └── testing
│   │       ├── service1-testing-db-01
│   │       └── service1-testing-web-01
│   ├── service2
│   ├── service3
│   │   ...
│   │
│   └── tool
│       └── tool-01
├── make-config.sh
└── run.sh
```

## 導入手順(メンテナー)

1. 本リポジトリをforkします(privateリポジトリにするのを忘れずに)
2. 組織形態に合わせてディレクトリ構成やSSHサーバの整理を行います

## 導入手順(SSHクライアント)

```shell
# 1. forkしたリポジトリを「git clone」します
$ git clone git@github.com:{user}/ssh-config-manager.git

# 2. configファイルを生成します
# - 「sh run.sh」を実行すると同一階層にconfigファイルができます
$ sh run.sh
▼ 実行モードを選択
[1] 環境: 全て, Include: On
[2] 環境: 全て, Include: Off
[3] 環境: 開発, Include: Off

実行します。よろしいですか？ (1/2/3/n [1])
完了しました。

# 3. configファイルのシンボリックリンクを作成します
# - シンボリックリンクを作成することでクライアントの追加・更新反映を容易にできます
$ cd ~/.ssh
$ ln -s /path/to/ssh-config-manager/config
```

## 更新手順(SSHクライアント)

```shell
# 以下の手順のみでconfigファイルを最新にできます
$ cd /path/to/ssh-config-manager
$ git pull
$ sh run.sh
```

## SSHサーバ追加・更新における留意点(メンテナー)

- ファイルを追加・更新した場合、ファイル最終行の改行を忘れずに入れてください
- 改行を入れないと次のSSHサーバと結合してしまい、うまく読み込めなくなります

```shell
Host service1-development-web-01
  HostName xxx.xxx.xxx.xxx
  User hoo
  Port 22
  IdentityFile ~/.ssh/bar.key
  IdentitiesOnly yes  # ← ファイル最終行は改行を忘れずに入れてください
                      # ← 何も書かれていない行
```

### 補足

#### 補足1: 実行モードの「環境」について

- 用途に応じてconfigファイルの内容を変えることができます
- 実行モード[1][2]: 全SSHサーバを記述します
- 実行モード[3]: 本番環境やツール等を除外したSSHサーバを記述します

#### 補足2: 実行モードの「Include」について

- Include: Onの場合
    - SSHサーバを記述したファイルへのフルパスをconfigファイルに記述します
    - Offの場合と比べて、configファイルの内容がすっきりします
    - 挙動はInclude: Offのときと変わりありません

```shell
# Includeキーワードを使用する場合(configファイルに記述される内容)
Include /path/to/ssh-config-manager/config.d/service1/development/service1-development-db-01
Include /path/to/ssh-config-manager/config.d/service1/development/service1-development-web-01
```

```shell
# Includeキーワードを使用しない場合(configファイルに記述される内容)
Host service1-development-db-01
  HostName xxx.xxx.xxx.xxx
  User hoo
  Port 22
  IdentityFile ~/.ssh/bar.key
  IdentitiesOnly yes

Host service1-development-web-01
  HostName xxx.xxx.xxx.xxx
  User hoo
  Port 22
  IdentityFile ~/.ssh/bar.key
  IdentitiesOnly yes
```

#### 補足3: configファイルのIncludeキーワードが読み込めない場合

- configファイルでIncludeキーワードを扱うためには`OpenSSH: 7.3`以上である必要があります
- OpenSSHのバージョンは以下のコマンドで確認できます
- バージョンが7.3より低い場合はアップデートするか、実行モード[2]で作成してください

```shell
$ ssh -V
OpenSSH_8.1p1, LibreSSL 2.7.3
```

#### 補足4: シェルでSSHサーバ名の補完が効かない場合

- Includeキーワードを使用したconfigファイルの場合、何らかの理由でIncludeキーワードが読み込めていない可能性があります
- Includeキーワードが原因で補完が効かない場合は、実行モード[2]でconfigファイルを再生成して、補完が効くか試してみてください

#### 補足5: 個人用のconfigを追加したい場合

- 個人で設定が違うようなものは`/config.d/private`配下にファイルを作成してください
- .gitignoreに`/config.d/private`配下のファイルを無視する設定を追加しているため、Git管理の対象外となります
