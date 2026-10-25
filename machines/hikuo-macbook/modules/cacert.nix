{ inputs', lib, ... }:
{
  # eMudhra の中間 CA（8 件）の秘密鍵が漏洩した（2026-10-20）。対策済みの cacert 3.131.1 は
  # nixpkgs-unstable に未反映のため、システムの CA バンドルのみ nixpkgs-master の master から取得する。
  # ponytail: nixpkgs-unstable の cacert が 3.131.1 以上になった時点で、本ファイルと nixpkgs-master input を削除する。
  security.pki.certificateFiles = lib.mkForce [
    "${inputs'.nixpkgs-master.legacyPackages.cacert}/etc/ssl/certs/ca-bundle.crt"
  ];
}
