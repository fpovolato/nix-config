{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix

    ../../modules/nixos/boot.nix
    ../../modules/nixos/filesystems.nix
    ../../modules/nixos/home-manager.nix
    ../../modules/nixos/hyprland.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/packages.nix
    ../../modules/nixos/ssh.nix
    ../../modules/nixos/users.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  time.timeZone = "Europe/Rome";

  # Compatibility baseline from the first installation, not an upgrade target.
  system.stateVersion = "26.05";
}
