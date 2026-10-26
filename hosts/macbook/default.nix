{ ... }:

{
  imports = [
    ../../modules/darwin/defaults.nix
    ../../modules/darwin/networking.nix
    ../../modules/darwin/security.nix
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/home-manager.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    primaryUser = "xhan";
    stateVersion = 7;
  };

  users.users.xhan.home = "/Users/xhan";

  # Nix daemon managed by the upstream installer.
  nix.enable = false;

  # Allow Homebrew Fish as a login shell.
  environment.shells = [
    "/opt/homebrew/bin/fish"
  ];
}
