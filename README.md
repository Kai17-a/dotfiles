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

認証後、GitHub CLI 経由で `~/dotfiles` へ clone してセットアップする。

```bash
gh repo clone Kai17-a/dotfiles ~/dotfiles
cd ~/dotfiles
bash init.sh
```

`init.sh` は次の順序でセットアップする。

1. `bin/mise` が固定バージョンのmiseをキャッシュへダウンロードする
2. mise設定をtrustする
3. `mise bootstrap --update` でAPTパッケージ、リポジトリ、dotfiles、CLIツールを適用する
4. GitHub CLI未認証時に使うログインコマンドを表示する

セットアップ完了後、新しいシェルを開始する。

```bash
exec bash
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

新しい環境でも、シェルが作成した既定の `~/.bashrc` が存在すると、mise は
次のようなエラーで停止する。

```text
mise ERROR files: refusing to overwrite existing files:
  ~/.bashrc
```

この場合は既存ファイルを日時付きで退避し、bootstrap を再実行する。

```bash
bashrc_backup="$HOME/.bashrc.before-dotfiles.$(date +%Y%m%d-%H%M%S)"
mv "$HOME/.bashrc" "$bashrc_backup"

cd ~/dotfiles
./bin/mise -C "$PWD" bootstrap --yes
```

適用後、必要な設定が退避ファイルに残っていないか確認する。

```bash
diff -u "$bashrc_backup" ~/dotfiles/.bashrc
```

`diff` の終了コード `1` は差分があることを表す。必要な設定だけを
`~/dotfiles/.bashrc` へ取り込み、不要になった退避ファイルは確認後に削除する。

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
