{ pkgs, ... }:

{
  home.packages = [
    pkgs.ghostty
  ];

  xdg.configFile."ghostty/config.ghostty".text = ''
    command = ${pkgs.fish}/bin/fish
  '';
}
