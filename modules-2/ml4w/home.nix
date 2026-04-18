# No-op for auto-discovery. Linux machines should import ./linux.nix directly.
# The body needs pkgsFromNiqs (Linux-only specialArg) and references services
# (swaync, etc.) that aren't available on darwin home-manager scope.
{ }
