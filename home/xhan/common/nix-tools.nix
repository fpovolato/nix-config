{ pkgs, ... }:

{
  # Shared Nix language servers; explicitly allowed outside Homebrew on macOS.
  home.packages = [
    pkgs.nil
    pkgs.nixd
  ];
}
