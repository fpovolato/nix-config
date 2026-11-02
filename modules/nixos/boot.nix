{ pkgs, ... }:

let
  # The shared wallpaper, blurred and darkened so the menu stays readable.
  limineWallpaper = pkgs.runCommand "limine-wallpaper.png" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } ''
    magick ${../../wallpapers/nixos-wallpaper-catppuccin-mocha.png} \
      -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -blur 0x18 -fill '#11111b' -colorize 45% \
      png24:$out
  '';
in
{
  boot.loader = {
    efi.canTouchEfiVariables = true;

    limine = {
      enable = true;
      maxGenerations = 10;
      enableEditor = false;

      # Catppuccin Mocha theme. Colors are RRGGBB; term background is TTRRGGBB,
      # where a higher TT is more transparent.
      style = {
        wallpapers = [ limineWallpaper ];
        wallpaperStyle = "stretched";

        interface = {
          branding = "NixOS";
          brandingColor = "cba6f7";
          helpColor = "89b4fa";
          helpColorBright = "b4befe";
        };

        graphicalTerminal = {
          font.scale = "2x2";
          foreground = "cdd6f4";
          background = "40181825";
          brightForeground = "ffffff";
          brightBackground = "45475a";
          palette = "1e1e2e;f38ba8;a6e3a1;f9e2af;89b4fa;cba6f7;94e2d5;bac2de";
          brightPalette = "585b70;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4";
          margin = 160;
          marginGradient = 24;
        };
      };
    };
  };
}
