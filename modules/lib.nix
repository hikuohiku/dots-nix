{ lib }:
let
  entries = builtins.readDir ./.;
  dirs = lib.filterAttrs (_: type: type == "directory") entries;
in
{
  # Collect <app>/default.nix (option definitions) + <app>/<filename> (implementation)
  # from all subdirectories.
  # e.g. collectAppModules "home.nix" -> [ ./fish/default.nix ./fish/home.nix ... ]
  collectAppModules =
    filename:
    lib.concatLists (
      lib.mapAttrsToList (
        name: _:
        let
          options = ./. + "/${name}/default.nix";
          impl = ./. + "/${name}/${filename}";
        in
        lib.optional (builtins.pathExists options) options
        ++ lib.optional (builtins.pathExists impl) impl
      ) dirs
    );
}
