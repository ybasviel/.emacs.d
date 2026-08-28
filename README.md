# Emacs Setup

モダンで最小限な Emacs 設定 (Emacs 29+ / elpaca / eglot / vertico stack)。

## 前提

- Emacs 29 以上（30 推奨）
- Git
- 外部検索/diff ツール (ripgrep / fd / difftastic)


## Arch Linux

```bash
yay -S emacs git ripgrep fd difftastic
```

## macOS (Homebrew)

```bash
brew install emacs
brew install git ripgrep fd difftastic mise
```

## Windows (PowerShell + winget)

```powershell
winget install --id GNU.Emacs
winget install --id Git.Git
winget install --id BurntSushi.ripgrep.MSVC
winget install --id sharkdp.fd
winget install --id Wilfred.difftastic
winget install --id jdx.mise

# 設定ファイルの場所
# Emacs は $HOME/.config/emacs/ を見る
# HOME が未設定なら PowerShell で通しておく:
#   [Environment]::SetEnvironmentVariable("HOME", $env:USERPROFILE, "User")
```

## 起動と初回動作

```bash
emacs
```

1. `*elpaca-bootstrap*` バッファが出て elpaca 自体を clone
2. `after-init-hook` で全パッケージが並列 install/build される
3. 初回のみ tree-sitter grammar のインストールを `y-or-n-p` で聞かれる → `y`
4. `M-x eglot` を初回に呼ぶと LSP バイナリのパスが解決される

進捗は `M-x elpaca-manager` で確認できる。

## MySQL
- Arch: `yay -S mariadb-clients`
- Mac: `brew install mysql-client`
- Windows: `winget install --id Oracle.MySQL`

シェル rc に以下を書いておくと `M-x sql-mysql-local` で一発接続:

```bash
export MYSQL_USER=root
export MYSQL_PASSWORD=secret     # または MYSQL_PWD
export MYSQL_HOST=127.0.0.1      # 省略時 127.0.0.1
export MYSQL_PORT=3306           # 省略時 3306
export MYSQL_DATABASE=myapp_dev
```

| コマンド | 動作 |
|---|---|
| `M-x sql-mysql-local` | 上記 env を毎回 `getenv` で読んで即接続 |
| `M-x sql-mysql` | 毎回プロンプトで user/pass/host 等を入力 |


## よくつかうやつ

| キー | 動作 |
|---|---|
| `C-x b` | バッファ切替 (consult-buffer) |
| `C-x C-r` | 最近開いたファイル |
| `M-s r` | ripgrep 検索 |
| `M-s f` | fd でファイル名検索 |
| `M-g i` | imenu でシンボルジャンプ |
| `M-.` / `M-?` | 定義 / 参照 (eglot) |
| `C-c r` / `C-c a` | rename / code-action |
| `C-x g` | magit-status |
| `D` (magit-diff内) | difftastic diff |
| `C-g` | キャンセル |
