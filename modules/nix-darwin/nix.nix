{
  nix.extraOptions = ''
    extra-experimental-features = nix-command flakes pipe-operators
  '';
}
