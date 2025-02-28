{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.symbols-only
      sarasa-gothic
      plemoljp
      plemoljp-nf
    ];
  };
}
