{ lib, ... }:

let
  aliases = import ../common/aliases.nix;

  fishAliases = lib.concatStringsSep "\n" (
    lib.mapAttrsToList
      (name: command:
        "alias ${name} ${lib.escapeShellArg command}"
      )
      aliases
  );
in
{
  imports = [
    ../common/git.nix
  ];

  home = {
    username = "xhan";
    homeDirectory = "/Users/xhan";
    stateVersion = "26.05";
  };

  # Configure Git without installing it via Nixpkgs.
  programs.git.package = null;

  # Fish is installed by Homebrew.
  # Home Manager only manages its aliases.
  home.file.".config/fish/conf.d/50-nix-aliases.fish".text =
    fishAliases + "\n";
}
