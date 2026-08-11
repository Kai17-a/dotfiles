# Private Dotfiles

個人用のプライベートリポジトリで管理する、Debian/Ubuntu 系 Linux 環境用の
Dotfiles。利用には、このリポジトリへアクセスできる GitHub アカウントが必要。

[miseの公式生成bootstrap](https://mise.jdx.dev/cli/generate/bootstrap.html)を
入口として、APTパッケージ、CLIツール、設定ファイルを
[`mise bootstrap`](https://mise.jdx.dev/bootstrap.html)で適用する。

## 対応環境

- Debian/Ubuntu 系 Linux
- `sudo` を実行できるユーザー
- インターネット接続
- Git、GitHub CLI、OpenSSH、curl、CA証明書、tar、sha256sum

現在の設定ではリポジトリの配置先を `~/dotfiles` としている。別のパスへ
clone すると、mise の `[bootstrap.repos]`、`[dotfiles]`、`.bashrc` の参照先と
一致しないため、必ずこのパスへ配置する。

## 新しい環境への移行

公式bootstrapを起動するための最低限のコマンドを先にインストールする。
これらはmise導入前に必要となるため、mise自身では導入できない。

```bash
sudo apt update
sudo apt install -y ca-certificates coreutils curl gh git openssh-client tar
```

GitHub CLI で、このプライベートリポジトリへアクセスできるアカウントに
ログインする。Git のプロトコルには SSH を選ぶ。SSH 鍵がなければ、対話中の
案内に従って作成・登録する。

```bash
gh auth login --hostname github.com --git-protocol ssh --web
gh config set git_protocol ssh --host github.com
gh auth status --hostname github.com
```

認証後、GitHub CLI 経由で `~/dotfiles` へ clone する。

```bash
gh repo clone Kai17-a/dotfiles ~/dotfiles
cd ~/dotfiles
```

新しい環境にも、OS やツールが作成した既存ファイルが存在する。`init.sh` は
miseの管理対象と競合するファイルを検出し、一覧を表示して退避の可否を
`Y/n` で確認する。

```bash
bash init.sh
```

`Y` または何も入力せずEnterを押すと、競合ファイルを階層構造ごと
`~/.dotfiles-backups/<日時>.<一意な文字列>/` へ移動してからセットアップを
続ける。`n` または `Y/n` 以外を入力した場合は、ファイルを移動せず後続処理も
実行しない。

`init.sh` は次の順序でセットアップする。

1. `bin/mise` が固定バージョンのmiseをキャッシュへダウンロードする
2. mise設定をtrustする
3. 既存dotfileとの競合を確認し、承認された場合だけバックアップへ移動する
4. `mise bootstrap --update` でAPTパッケージ、リポジトリ、dotfiles、CLIツールを適用する
5. GitHub CLI の認証を確認し、Git のプロトコルを SSH に設定する

GitHub CLI が未認証の場合は、SSH を使ってログインするためのコマンドを表示する。

セットアップ後、バックアップに引き継ぐべき設定がないか確認する。

```bash
find ~/.dotfiles-backups \( -type f -o -type l \)
```

必要な設定だけをdotfilesへ取り込み、確認後に不要なバックアップを削除する。

最後に新しいシェルを開始する。

```bash
exec bash
```

## その他の既存ファイル

miseが競合として検出する主な管理対象は次のとおり。

- `~/.config/git`
- `~/.config/helix`
- `~/.config/mise`
- `~/.config/wezterm`
- `~/.config/zellij`
- `~/.local/bin` 内の管理対象ファイル

セットアップ前に管理対象を確認したい場合は、次を実行する。

```bash
./bin/mise -C "$PWD" bootstrap --dry-run
```

競合があると、mise は次のようなエラーで停止する。

```text
mise ERROR files: refusing to overwrite existing files:
  <既存ファイル>
```

通常は `init.sh` が競合ファイルを退避するため、`--force-dotfiles` は使用しない。

## 設定の再適用

設定を更新した環境では、リポジトリをfast-forwardしてからbootstrapを
再実行する。

```bash
cd ~/dotfiles
git pull --ff-only
./bin/mise -C "$PWD" bootstrap --yes
```

bootstrapは宣言済みの状態を確認し、適用済みの項目をスキップするため、
繰り返し実行できる。

状態だけを確認する場合:

```bash
cd ~/dotfiles
./bin/mise -C "$PWD" bootstrap status
./bin/mise -C "$PWD" doctor
```

## mise本体の更新

`bin/mise` は `mise generate bootstrap` で生成した公式スクリプトで、miseの
バージョンを固定している。

最新版へ更新するときは、GitHub Releasesの最新タグを取得し、`bin/mise`を
再生成する。

```bash
cd ~/dotfiles

RELEASE_URL="$(
  curl -fsSL \
    -o /dev/null \
    -w '%{url_effective}' \
    https://github.com/jdx/mise/releases/latest
)"

VERSION="${RELEASE_URL##*/}"
VERSION="${VERSION#v}"

./bin/mise generate bootstrap \
  --version "$VERSION" \
  --write bin/mise

./bin/mise --version

git add bin/mise
git commit -m "chore(mise): update to ${VERSION}"
```

## 補足

- APIキー、SSH秘密鍵などの秘密情報はこのリポジトリでは管理しない
- OSパッケージはAPTで宣言しているため、現在の完全なセットアップ対象はDebian/Ubuntu系のみ
- `bin/mise` は生成物なので、手作業で編集せず `mise generate bootstrap` で更新する
