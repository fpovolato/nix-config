{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    gitleaks
    neovim
    tree
    curl
  ];
}
