{
  pkgs,
  userInfo,
  ...
}: {
  imports = [
    # 必要に応じて追加のデスクトップ環境設定をここにインポート
  ];

  home.packages = with pkgs; [
    # システムユーティリティ
    pavucontrol     # 音声設定GUI
    mission-center  # システムモニタリング
    gnome-software  # ソフトウェアセンター
    flatpak         # Flatpakサポート

    # ファイル管理
    nautilus        # GNOMEファイルマネージャー

    # コミュニケーション
    slack           # ビジネスチャット
    teams-for-linux # Microsoft Teams
    discord         # コミュニティチャット

    # メディア
    vlc             # マルチメディアプレーヤー
  ];

  # デスクトップ環境の設定
  xdg = {
    enable = true;
    # 必要に応じてXDGの設定を追加
  };

  # デスクトップエントリ（.desktop files）の設定
  # 必要に応じて追加

  # その他のデスクトップ関連の設定
  # GTK/Qt テーマ設定など
}