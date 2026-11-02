{ pkgs, zen-browser, ... }:

# Applications shared with the MacBook (Homebrew casks and formulae in
# modules/darwin/homebrew.nix) that Nixpkgs provides for Linux. Unfree ones
# are allowed in modules/nixos/nixpkgs.nix. Zen comes from the zen-browser
# flake input. Not available: ZenNotes, Helium, ChatGPT, Claude desktop and
# ArtCraft.
{
  home.packages = with pkgs; [
    # Normie apps
    discord
    obsidian
    spotify

    # Browsers (Chromium is in chromium.nix)
    brave
    librewolf
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Terminal stuff
    tmux
    tuios

    # Coding
    claude-code
    mkcert
    zed-editor
  ];
}
