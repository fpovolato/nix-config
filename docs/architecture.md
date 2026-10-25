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
