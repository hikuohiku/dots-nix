{
  # Claude Code (user: hikuo) は対話的 sudo をしない方針だが、検証フローのため
  # darwin-rebuild の activation だけ passwordless で許可する。
  # 個人専用マシンのため許容（実質この経路に限った passwordless root）。
  # 一般 sudo は従来どおりパスワード必須。
  #
  # nix-darwin には NixOS の security.sudo.extraRules が無いため、native な
  # security.sudo.extraConfig（sudoers への追記）で同等の許可を与える。
  # hikuo-desktop 側の nixos-rebuild NOPASSWD 設定 (claude-rebuild.nix) の darwin 版。
  security.sudo.extraConfig = ''
    hikuo ALL=(root) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';
}
