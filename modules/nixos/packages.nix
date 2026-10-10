{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    neovim
    tree
    curl
  ];
}
