{ lib, pkgs, ... }:

{
  # On macOS the executables are installed through Homebrew.
  programs.fish.enable = pkgs.stdenv.isLinux;
  programs.starship = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
  };

  home.file.".config/fish/conf.d/70-prompt.fish".text = ''
    set -g fish_greeting
  '' + lib.optionalString pkgs.stdenv.isDarwin ''
    if status is-interactive; and test "$TERM" != dumb
      /opt/homebrew/bin/starship init fish | source
    end
  '';
}
