{ ... }:

{
  imports = [
    ../common/ghostty.nix
  ];

  programs.ghostty = {
    # Ghostty is installed through Homebrew.
    # Home Manager manages configuration only.
    package = null;
  };
}
