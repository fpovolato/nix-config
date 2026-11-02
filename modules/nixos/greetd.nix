{ config, lib, pkgs, ... }:

# ReGreet is the graphical greeter for greetd, the display manager started at
# boot; Hyprland is offered from the session list registered by
# programs.hyprland.
#
# ReGreet fullscreens on the first monitor it finds, so instead of the NixOS
# module's default Cage kiosk it runs in a minimal Hyprland instance
# (./greetd/hyprland.lua) that only enables the LG main monitor.
let
  hyprland = config.programs.hyprland.package;

  greeterConfig = pkgs.replaceVars ./greetd/hyprland.lua {
    regreet = lib.getExe config.programs.regreet.package;
    hyprctl = "${hyprland}/bin/hyprctl";
  };
in
{
  programs.regreet = {
    enable = true;

    # Magnetic Catppuccin GTK theme (flat, rounded, with GTK 4 support),
    # restyled by ./greetd/regreet.css.
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

    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
    };

    font = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
      size = 14;
    };

    extraCss = ./greetd/regreet.css;

    settings = {
      background = {
        path = "${../../wallpapers/nixos-wallpaper-catppuccin-mocha.png}";
        fit = "Cover";
      };

      GTK.application_prefer_dark_theme = true;

      appearance.greeting_msg = "Welcome back";

      widget.clock = {
        # ReGreet falls back to its default format on non-ASCII characters.
        format = "%A %d %B  %H:%M";
        timezone = "Europe/Rome";
        label_width = 320;
      };
    };
  };

  services.greetd.settings.default_session.command =
    "${pkgs.dbus}/bin/dbus-run-session ${hyprland}/bin/start-hyprland -- --config ${greeterConfig}";

  # Hyprland keeps state and logs under the greeter's home and runtime
  # directories; the greetd module's system user has no home by default.
  users.users.greeter = {
    home = "/var/lib/greeter";
    createHome = true;
  };
}
