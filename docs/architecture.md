# System Architecture

## Overview

This project manages a NixOS desktop and a macOS laptop
using one shared Git repository and one Nix Flake.

The repository is currently private, with a possible
future transition to public visibility.

## Hosts

### nixos

- Platform: x86_64-linux
- Operating system: NixOS 26.05
- User: xhan
- Window manager: Hyprland
- Shell: Fish
- Package management: Nixpkgs
- User configuration: Home Manager

### macbook

- Platform: aarch64-darwin
- Hardware: MacBook Pro M2
- Operating system: macOS
- User: xhan
- System configuration: nix-darwin 26.05
- Nix implementation: upstream Nix
- Homebrew installation: nix-homebrew
- Package management: Homebrew Bundle via nix-darwin
- User configuration: Home Manager

The macOS Nix daemon is currently managed by the
NixOS Community installer, not nix-darwin.

The option `nix.enable = false` preserves this arrangement.

## Flake Inputs

- nixpkgs: nixos-26.05
- nixpkgs-darwin: nixpkgs-26.05-darwin
- home-manager: release-26.05
- nix-darwin: nix-darwin-26.05
- nix-homebrew

The exact input revisions are recorded in `flake.lock`.

## Configuration Layers

### System

NixOS modules configure Linux services, users, boot
and the desktop environment.

nix-darwin modules configure macOS and orchestrate Homebrew.

macOS settings are split by purpose under `modules/darwin/`:

- `defaults.nix`: user-facing macOS preferences, including the battery
  percentage in the menu bar for the primary user.
- `security.nix`: authentication settings, including Touch ID for `sudo`
  through `security.pam.services.sudo_local.touchIdAuth`.
- `homebrew.nix`: application installation.
- `home-manager.nix`: user configuration integration.

After activation, log out and back in if the menu bar has not refreshed.
Touch ID requires an enrolled fingerprint. To check it from a local terminal,
run `sudo -k` followed by `sudo -v`; password authentication remains available.

### Package Installation

NixOS uses Nixpkgs.

macOS uses Homebrew for global CLI and GUI applications.

The macOS Homebrew configuration is located at:
`modules/darwin/homebrew.nix`.

### User Environment

Home Manager manages user-level settings.

Common configuration belongs in:
`home/xhan/common/`.

Platform-specific configuration belongs in:
`home/xhan/linux/` or `home/xhan/darwin/`.

The shared alias definitions are in:
`home/xhan/common/aliases.nix`.

On macOS, Home Manager generates Fish alias configuration
without installing another copy of Fish.

Fish uses the default Starship prompt and has its welcome message disabled
on both hosts. The shared configuration is in `home/xhan/common/fish.nix`.
On NixOS, Home Manager's Fish and Starship modules install the programs
and enable prompt integration. On macOS, Homebrew installs both programs;
Home Manager manages the Fish initialization file. The pinned Home Manager
modules require packages and would otherwise install Nix copies on macOS.

### Rebuilding from Fish

With this configuration activated, type `bswitch` and press Enter in
interactive Fish. It expands to a build followed by activation only on
success (`&&`), using `~/nix-config` regardless of the working directory.
The repository must be cloned at that path on both hosts.

- NixOS builds `nixosConfigurations.nixos.config.system.build.toplevel`,
  then runs `sudo nixos-rebuild switch --flake ~/nix-config#nixos`.
- macOS builds `darwinConfigurations.macbook.system`, then runs
  `sudo darwin-rebuild switch --flake ~/nix-config#macbook`.

The build uses `nix build --no-link`. Activation may prompt for a sudo
password. The rebuild command reuses the build when the inputs are unchanged.
The name `bswitch` avoids the reserved Fish keyword `switch`.
This is an interactive abbreviation; abbreviations do not expand in scripts. See the
[Fish abbreviation documentation](https://fishshell.com/docs/current/cmds/abbr.html).

The Fish alias `update` updates all flake inputs in `~/nix-config/flake.lock`
and builds the host configuration before applying it. On macOS, after the
build it also runs `brew update` and `brew upgrade --greedy` before activation.
This upgrades installed, unpinned Homebrew packages, including casks with
automatic updates or `version :latest`. It does not install macOS OS updates
or update packages managed outside Nix and Homebrew.
Each step uses `&&` to stop on failure. Earlier changes (including the lockfile
and any completed Homebrew upgrades) are not rolled back if a later step fails.
Flake updates follow the branches declared in `flake.nix`; they do not change
release branches or state versions. Review and commit the lockfile separately.

## Development Environments

University and software projects can use independent
Flakes and `nix develop` for project-specific toolchains.

These environments are separate from globally installed
Homebrew applications on macOS.

## Secrets

A separate private `nix-secrets` repository is planned.

Agenix is the intended initial encryption solution.

Secret repository integration, recipient configuration
and recovery procedures are not implemented yet.

No plaintext secrets belong in this repository.

## Operational Considerations

Nix Flake inputs are pinned by `flake.lock`.

Homebrew packages are not fully reproducible solely from
this lockfile: available formula and cask versions can change.

macOS Homebrew activation currently uses:
- autoUpdate = false
- upgrade = false
- cleanup = "none"

State versions should not be increased automatically.

## Documentation Policy

Keep AGENTS.md and docs updated when architecture changes.

Do not document planned features as already implemented.
