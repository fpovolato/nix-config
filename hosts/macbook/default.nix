{ ... }:

{
  imports = [
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/home-manager.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    primaryUser = "xhan";
    stateVersion = 7;
  };

  users.users.xhan.home = "/Users/xhan";

  # Nix is managed by the upstream installer.
  nix.enable = false;
}
