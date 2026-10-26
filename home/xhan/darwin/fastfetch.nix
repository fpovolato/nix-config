{ ... }:

let
  # Thin grey rule between module groups.
  rule = {
    type = "custom";
    format = "──────────────────────";
    outputColor = "90";
  };
in
{
  programs.fastfetch = {
    enable = true;

    # Fastfetch is installed through Homebrew.
    # Home Manager manages configuration only.
    package = null;

    settings = {
      # Nix snowflake with the Apple logo in its centre, as an image.
      # "kitty-direct" makes Ghostty read the PNG itself, so fastfetch needs
      # no ImageMagick. Width and height are in terminal cells (cells are
      # about twice as tall as wide, so 34x17 keeps the image square).
      # In terminals without the Kitty graphics protocol, switch back to the
      # ASCII version: type = "file", source = ./fastfetch/logo.txt, with
      # color = { "1" = "blue"; "2" = "cyan"; "3" = "white"; }.
      logo = {
        type = "kitty-direct";
        source = ./fastfetch/logo.png;
        width = 34;
        height = 17;
        padding = {
          top = 1;
          right = 4;
        };
      };

      # Minimal style: Nerd Font icons as keys, short values.
      # The icons need a Nerd Font (JetBrains Mono Nerd Font in Ghostty).
      display = {
        separator = "  ";
        color = {
          keys = "blue";
          output = "default";
        };
      };

      modules = [
        {
          type = "title";
          format = "{user-name}@{host-name}";
          color = {
            user = "blue";
            at = "white";
            host = "cyan";
          };
        }
        rule
        { type = "os"; key = ""; format = "{name} {version}"; }
        { type = "kernel"; key = ""; format = "{sysname} {release}"; }
        { type = "uptime"; key = "󰅐"; }
        { type = "packages"; key = "󰏖"; format = "{all}"; }
        { type = "shell"; key = ""; format = "{pretty-name}"; }
        { type = "terminal"; key = ""; format = "{pretty-name}"; }
        { type = "wm"; key = ""; format = "{pretty-name}"; }
        rule
        { type = "cpu"; key = ""; format = "{name}"; }
        { type = "memory"; key = "󰍛"; format = "{used} / {total}"; }
        { type = "disk"; key = "󰋊"; format = "{size-used} / {size-total}"; folders = "/"; }
        { type = "battery"; key = "󰁹"; format = "{capacity}"; }
        "break"
        { type = "colors"; symbol = "circle"; }
      ];
    };
  };
}
