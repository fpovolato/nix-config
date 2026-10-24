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

  home.shellAliases = {
    ls = "eza -la";
    ll = "eza -la";
    tree = "eza --tree";

    cat = "bat";
    find = "fd";
    grep = "rg";

    json = "jq";
    fuzzy = "fzf";
  };
}
