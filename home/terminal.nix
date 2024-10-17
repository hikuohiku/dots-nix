{ ... }:
{
  # alacritty
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 8;
          y = 8;
        };
        decorations = "none";
        opacity = 0.7;
      };
      font.size = 12;
      cursor = {
        style.shape = "Beam";
        style.blinking = "On";
        vi_mode_style.shape = "Block";
      };
    };
  };
  # kitty
  programs.kitty.enable = true;

  # fish
  programs.fish.enable = true;
  # starship
  programs.starship.enable = true;

  # zellij
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "catppuccin-latte";
      default_mode = "locked";
      ui.pane_frames.rounded_corners = true;
    };
  };
}
