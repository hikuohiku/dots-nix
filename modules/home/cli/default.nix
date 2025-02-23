{ pkgs, ... }: {
  imports = [
    # 必要に応じて追加のCLIツール設定をここにインポート
  ];

  home.packages = with pkgs; [
    # システム管理ツール
    nix-output-monitor # Nixビルド出力の改善
    tree              # ディレクトリ構造の表示
    fastfetch         # システム情報の表示
    gomi              # ゴミ箱機能
    rlwrap           # readlineラッパー

    # 開発ツール
    gh               # GitHub CLI
    bitwarden-cli    # パスワード管理
    vhs              # ターミナル画面キャプチャ

    # モダンなコマンドラインツール（Rust実装）
    ripgrep          # 高速なgrep代替
    fd               # 直感的なfind代替
    sd               # 使いやすいsed代替

    # アーカイブツール
    unar             # 汎用解凍ツール
    unzip            # ZIP形式の解凍
    p7zip            # 7z形式の圧縮・解凍

    # ネットワークツール
    wget             # ファイルダウンロード
    httpie           # 人間にやさしいHTTPクライアント

    # データフォーマット処理
    yq               # YAML処理
    jwt-cli          # JWT解析
    jq               # JSON処理
    jnv              # JSON可視化

    # TUIアプリケーション
    btop             # システムモニター
    ranger           # ファイルマネージャー
    lazydocker       # Dockerマネージャー
  ];

  # CLIプログラムの設定
  programs = {
    # ファイル表示の改善
    bat.enable = true;

    # モダンなls代替
    eza = {
      enable = true;
      enableFishIntegration = false;  # fish用の設定は別途管理
    };

    # ファジーファインダー
    fzf = {
      enable = true;
      enableFishIntegration = false;  # fish用の設定は別途管理
      defaultOptions = [
        "--cycle"
        "--layout=reverse"
        "--border"
        "--height=90%"
        "--preview-window=wrap"
        ''--marker="*"''
      ];
    };

    # 環境変数の自動読み込み
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}