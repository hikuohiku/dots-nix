{ lib, ... }:
let
  mylib = import ./lib.nix { inherit lib; };
in
{
  imports = mylib.collectAppModules "home.nix";
}
