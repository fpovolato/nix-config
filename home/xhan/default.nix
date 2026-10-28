{ config, ... }:

{
  imports = [
    ./common/cli.nix
    ./common/fish.nix
    ./common/git.nix
    ./common/nix-tools.nix
    ./linux/chromium.nix
    ./linux/ghostty.nix
  ];

  # Build and activate from interactive Fish.
  programs.fish.shellAbbrs.bswitch =
    "nix build ~/nix-config#nixosConfigurations.nixos.config.system.build.toplevel --no-link"
    + " && sudo nixos-rebuild switch --flake ~/nix-config#nixos";

  programs.fish.shellAliases.update =
    "nix flake update --flake ~/nix-config"
    + " && " + config.programs.fish.shellAbbrs.bswitch;

  home = {
    username = "xhan";
    homeDirectory = "/home/xhan";
    stateVersion = "26.05";
  };
}
