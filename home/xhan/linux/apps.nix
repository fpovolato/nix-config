{ pkgs, ... }:

# Applications shared with the MacBook (Homebrew casks and formulae in
# modules/darwin/homebrew.nix) that Nixpkgs provides for Linux. Unfree ones
# are allowed in modules/nixos/nixpkgs.nix. Not available in Nixpkgs:
# ZenNotes, Zen, Helium, ChatGPT, Claude desktop and ArtCraft.
{
  home.packages = with pkgs; [
    # Normie apps
    discord
    obsidian
    spotify

    # Terminal stuff
    tmux
    tuios

    # Coding
    claude-code
    mkcert
    zed-editor
  ];
}
