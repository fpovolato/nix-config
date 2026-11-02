{ pkgs, ... }:

{
  # Cursor for Hyprland, GTK and XWayland applications. Hyprland receives the
  # same name and size in hyprland/env.lua.
  home.pointerCursor = {
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
    size = 24;
    gtk.enable = true;
  };

  # Magnetic Catppuccin GTK theme and icons, matching the greeter.
  gtk = {
    enable = true;

    theme = {
      package = pkgs.magnetic-catppuccin-gtk.override {
        accent = [ "mauve" ];
        shade = "dark";
      };
      name = "Catppuccin-GTK-Mauve-Dark";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
