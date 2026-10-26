{ ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "Catppuccin Mocha";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 16;
      window-decoration = "none";
      cursor-style = "block";
      # Shell integration otherwise switches to a bar cursor at the prompt.
      shell-integration-features = "no-cursor";
      # Animated cursor trail; requires custom-shader-animation (default on).
      custom-shader = "${./ghostty/cursor-trail.glsl}";
    };
  };
}
