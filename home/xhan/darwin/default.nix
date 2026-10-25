{ lib, ... }:

let
  aliases = import ../common/aliases.nix;
  buildCommand = "nix build ~/nix-config#darwinConfigurations.macbook.system --no-link";
  switchCommand = "sudo darwin-rebuild switch --flake ~/nix-config#macbook";
  updateCommand = "nix flake update --flake ~/nix-config"
    + " && " + buildCommand
    + " && brew update && brew upgrade --greedy"
    + " && " + switchCommand;

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
    ../common/fish.nix
    ../common/git.nix
    ./ghostty.nix
  ];

  home = {
    username = "xhan";
    homeDirectory = "/Users/xhan";
    stateVersion = "26.05";
  };

  # Git is installed through Homebrew.
  programs.git.package = null;

  # Fish is installed through Homebrew.
  # Home Manager only manages its configuration.

  home.file.".config/fish/conf.d/10-environment.fish".text = ''
    # Initialize upstream Nix.
    if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    end

    # Make nix-darwin commands available.
    if test -d /run/current-system/sw/bin
      fish_add_path --path --move /run/current-system/sw/bin
    end

    # Initialize Homebrew and prioritize its applications.
    if test -x /opt/homebrew/bin/brew
      eval (/opt/homebrew/bin/brew shellenv fish)
    end
  '';

  # Shared aliases with NixOS.
  home.file.".config/fish/conf.d/50-nix-aliases.fish".text =
    fishAliases + "\n";

  # Build and activate from interactive Fish.
  home.file.".config/fish/conf.d/60-nix-rebuild.fish".text = ''
    abbr --add bswitch ${lib.escapeShellArg (buildCommand + " && " + switchCommand)}
    alias update ${lib.escapeShellArg updateCommand}
  '';
}
