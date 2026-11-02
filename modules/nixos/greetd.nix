{ pkgs, ... }:

# ReGreet is the graphical greeter for greetd, the display manager started at
# boot. The NixOS module enables greetd and runs ReGreet inside the Cage kiosk
# compositor; Hyprland is offered from the session list registered by
# programs.hyprland.
{
  programs.regreet = {
    enable = true;

    # Show the greeter on the last connected output only, instead of
    # stretching it across both monitors.
    cageArgs = [
      "-s"
      "-d"
      "-m"
      "last"
    ];

    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
    };

    font = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
      size = 14;
    };

    settings = {
      background = {
        path = "${../../wallpapers/nixos-wallpaper-catppuccin-mocha.png}";
        fit = "Cover";
      };

      GTK.application_prefer_dark_theme = true;

      appearance.greeting_msg = "Welcome back!";

      widget.clock = {
        format = "%a %d %b  %H:%M";
        timezone = "Europe/Rome";
      };
    };
  };
}
