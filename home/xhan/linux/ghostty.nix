{ pkgs, ... }:

{
  imports = [
    ../common/ghostty.nix
  ];

  programs.ghostty = {
    package = pkgs.ghostty;

    settings.command = "${pkgs.fish}/bin/fish";

    systemd.enable = false;
  };
}
