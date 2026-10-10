{
  imports = [
    ./common/fish.nix
    ./common/git.nix
    ./linux/ghostty.nix
  ];

  home = {
    username = "xhan";
    homeDirectory = "/home/xhan";
    stateVersion = "26.05";
  };
}
