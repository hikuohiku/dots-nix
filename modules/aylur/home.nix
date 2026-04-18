# No-op for auto-discovery. Linux machines should import ./linux.nix directly.
# Cannot conditionally import based on pkgs.stdenv.hostPlatform without infinite
# recursion, and the body references options (catppuccin, wayland.windowManager)
# that don't exist on darwin home-manager scope.
{ }
