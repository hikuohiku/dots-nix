{ ... }:
{
  system.activationScripts.postActivation.text = ''
    # Syncthingをファイアウォールに登録
    /usr/libexec/ApplicationFirewall/socketfilterfw --add /etc/profiles/per-user/hikuo/bin/syncthing 2>/dev/null || true
    /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /etc/profiles/per-user/hikuo/bin/syncthing 2>/dev/null || true
  '';
}
