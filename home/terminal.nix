{ ... }:
{
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
}
