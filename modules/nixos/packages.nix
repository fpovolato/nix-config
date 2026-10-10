{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    ghostty
    neovim
    tree
    curl
  ];
}
