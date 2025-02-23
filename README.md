# hikuohiku dotfiles

NixOS及びHome Managerを使用した個人用システム設定です。Nix Flakesを活用して、再現性の高い環境構築を実現しています。

## ディレクトリ構造

```
.
├── flake.nix          # Flake設定のエントリーポイント
├── config/            # 共通設定
│   ├── user.nix      # ユーザー情報
│   └── fcitx/        # 入力メソッドの設定
├── hosts/            # ホスト固有の設定
│   └── desktop/      # デスクトップマシンの設定
│       ├── default.nix   # メインの設定
│       ├── hardware.nix  # ハードウェア設定
│       └── nvidia.nix    # NVIDIA固有の設定
├── modules/          # 再利用可能なモジュール
│   ├── nixos/       # NixOS用モジュール
│   │   ├── desktop/ # デスクトップ環境
│   │   └── base/    # 基本システム設定
│   └── home/        # Home Manager用モジュール
│       ├── desktop/ # デスクトップアプリケーション
│       └── cli/     # CLIツール
└── home/            # レガシーな設定（移行中）
    └── unixporn/    # カスタマイズ設定
```

## 特徴

- モジュール化された設定で再利用性と保守性を向上
- ハードウェア設定とソフトウェア設定の明確な分離
- デスクトップ環境（Hyprland, KDE）のサポート
- 日本語環境の完全なサポート（Fcitx5 + Mozc）
- 開発環境の自動セットアップ

## セットアップ方法

1. NixOSをインストール
2. このリポジトリをクローン:
   ```bash
   git clone https://github.com/hikuohiku/dotfiles.git ~/.dotfiles
   ```
3. システムの再構築:
   ```bash
   sudo nixos-rebuild switch --flake ~/.dotfiles
   ```
4. Home Managerの設定の適用:
   ```bash
   home-manager switch --flake ~/.dotfiles
   ```

## カスタマイズ

- `config/user.nix`: ユーザー情報の設定
- `hosts/desktop/`: デスクトップマシン固有の設定
- `modules/home/`: ユーザー環境のカスタマイズ

## 参考

以下のプロジェクトからインスピレーションを得ています：

- [Comamoca/dotfiles](https://github.com/Comamoca/dotfiles)
- ~~[mylinuxforwork/dotfiles](https://github.com/mylinuxforwork/dotfiles)~~

## ライセンス

MITライセンスの下で公開されています。
