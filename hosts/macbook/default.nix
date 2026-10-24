{ ... }:

{
  imports = [
    ../../modules/darwin/homebrew.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    primaryUser = "xhan";
    stateVersion = 7;
  };

  users.users.xhan.home = "/Users/xhan";

  # Preserve the existing Nix installation.
  nix.enable = false;
}
