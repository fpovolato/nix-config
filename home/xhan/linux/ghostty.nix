{ pkgs, ... }:

{
  imports = [
    ../common/ghostty.nix
  ];

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;

  programs.ghostty = {
    package = pkgs.ghostty;

    settings.command = "${pkgs.fish}/bin/fish";

    systemd.enable = false;
  };
}
