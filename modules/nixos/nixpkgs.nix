{ lib, ... }:

{
  # Unfree packages are allowed one by one. Home Manager shares this
  # configuration through home-manager.useGlobalPkgs.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
      "obsidian"
      "spotify"
    ];
}
