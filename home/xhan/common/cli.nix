{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    jq
  ];

  programs = {
    bat.enable = true;
    eza.enable = true;
    ripgrep.enable = true;

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  home.shellAliases = import ./aliases.nix;
}
