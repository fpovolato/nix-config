{
  programs.hyprland = {
    enable = true;
    withUWSM = false;
    xwayland.enable = true;
  };

  # Stores GTK and portal settings written by Home Manager (dark color scheme).
  programs.dconf.enable = true;
}
