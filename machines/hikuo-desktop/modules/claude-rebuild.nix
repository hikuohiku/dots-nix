{
  # Claude Code (user: hikuo) は対話的 sudo をしない方針だが、検証フローのため
  # nixos-rebuild の activation だけ passwordless で許可する。
  # 個人専用デスクトップのため許容（実質この経路に限った passwordless root）。
  # 一般 sudo は従来どおりパスワード必須。
  security.sudo.extraRules = [
    {
      users = [ "hikuo" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
