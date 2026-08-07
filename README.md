# Dotfiles

Debian/Ubuntu 系 Linux 環境用の Dotfiles。

[miseの公式生成bootstrap](https://mise.jdx.dev/cli/generate/bootstrap.html)を
入口として、APTパッケージ、CLIツール、設定ファイルを
[`mise bootstrap`](https://mise.jdx.dev/bootstrap.html)で適用する。

## 対応環境

- Debian/Ubuntu 系 Linux
- `sudo` を実行できるユーザー
- インターネット接続
- Git、curl、CA証明書、tar、sha256sum

現在の設定ではリポジトリの配置先を `~/dotfiles` としている。別のパスへ
clone すると、mise の `[bootstrap.repos]`、`[dotfiles]`、`.bashrc` の参照先と
一致しないため、必ずこのパスへ配置する。

## 新しい環境への移行

公式bootstrapを起動するための最低限のコマンドを先にインストールする。
これらはmise導入前に必要となるため、mise自身では導入できない。

```bash
sudo apt update
sudo apt install -y ca-certificates coreutils curl git tar
```

SSH 鍵をまだ用意していない環境でも取得できるよう、最初は HTTPS で clone
する。

```bash
git clone https://github.com/Kai17-a/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash init.sh
```

`init.sh` は次の順序でセットアップする。

1. `bin/mise` が固定バージョンのmiseをキャッシュへダウンロードする
2. mise設定をtrustする
3. `mise bootstrap --update` でAPTパッケージ、リポジトリ、dotfiles、CLIツールを適用する
4. 必要であればGitHub CLIのログイン手順を表示する

セットアップ完了後、新しいシェルを開始する。

```bash
exec bash
```

GitHub CLIへログインする場合は、表示された案内に従う。

```bash
gh auth login --hostname github.com
```

## 既存ファイルがある環境

mise は、管理対象に既存の実ファイルやディレクトリがある場合、勝手に
上書きせず競合として停止する。主な管理対象は次のとおり。

- `~/.bashrc`
- `~/.config/git`
- `~/.config/helix`
- `~/.config/mise`
- `~/.config/wezterm`
- `~/.config/zellij`
- `~/.local/bin` 内の管理対象ファイル

既存の設定が必要な場合は、`init.sh` 実行前にバックアップして差分を確認する。
bootstrap部分だけを事前確認するには、リポジトリ内で次を実行する。

```bash
./bin/mise -C "$PWD" bootstrap --dry-run
```

競合を強制置換する `--force-dotfiles` は、バックアップと差分確認が済んだ場合
にのみ使用する。

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
