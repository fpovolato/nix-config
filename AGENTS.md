# Nix Configuration — Agent Instructions

## Project

This repository manages two machines with a shared Nix Flake:

- `nixos`: x86_64-linux desktop running NixOS.
- `macbook`: aarch64-darwin MacBook Pro M2 running macOS.

The goal is a modular, reproducible, documented configuration
that can be maintained by humans and coding agents.

## Core Rules

1. Use official documentation first:
   - Nix: https://nix.dev/
   - NixOS: https://nixos.org/manual/nixos/stable/
   - nix-darwin: https://nix-darwin.github.io/nix-darwin/manual/
   - Home Manager: https://nix-community.github.io/home-manager/
   - nix-homebrew: https://github.com/zhaofengli/nix-homebrew

2. Prefer modular configuration over large monolithic files.
3. Reuse shared modules when behavior is truly cross-platform.
4. Keep Linux-specific and Darwin-specific settings separate.
5. Document architectural decisions and important changes.
6. Validate changes before proposing activation.
7. Never deploy system changes without explicit authorization.

## Package Management

### NixOS

Use Nixpkgs for system and user packages.

Home Manager may install packages and manage configuration.

### macOS

Global applications and CLI tools MUST be installed via Homebrew,
declared in the nix-darwin Homebrew configuration.

- Use `homebrew.brews` for CLI tools.
- Use `homebrew.casks` for GUI applications.
- Use `nix-homebrew` to manage the Homebrew installation.
- Use Home Manager primarily for dotfiles and application settings.
- Do not use `home.packages` or `environment.systemPackages`
  for ordinary macOS applications.
- Check whether Home Manager program modules implicitly install
  packages before enabling them.

Nix may still provide internal build and activation dependencies.

Explicit exception: the Nix language servers `nil` and `nixd` are installed
through Home Manager in `home/xhan/common/nix-tools.nix` on both hosts,
because they are unavailable in the configured Homebrew repositories.

Project-specific development environments may use Nix Flakes
and `nix develop`, separately from global application management.

## Repository Structure

- `flake.nix`: entry point and host outputs.
- `flake.lock`: pinned Flake dependencies.
- `hosts/nixos/`: NixOS host configuration.
- `hosts/macbook/`: macOS host configuration.
- `modules/nixos/`: Linux system modules.
- `modules/darwin/`: macOS system modules.
- `home/xhan/common/`: reusable user configuration.
- `home/xhan/linux/`: Linux-only user configuration.
- `home/xhan/darwin/`: macOS-only user configuration.
- `docs/`: architectural and operational documentation.

## Secrets and Security

The separate private `nix-secrets` repository is planned but
not yet integrated.

Never commit plaintext credentials, private keys, tokens,
passwords or other sensitive information.

Never place plaintext secrets in the Nix Store.

Agents must not access private secrets or decryption keys
unless explicitly authorized.

Do not assume a private Git repository provides local
filesystem isolation for agents.

## Validation

From the repository root:

Evaluate NixOS:
  nix eval --raw .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath

Evaluate macOS:
  nix eval --raw .#darwinConfigurations.macbook.config.system.build.toplevel.drvPath

Build macOS without activation:
  nix build '.#darwinConfigurations.macbook.system' --no-link

Validate staged changes:
  git diff --cached --check

Never automatically execute `nixos-rebuild switch` or
`darwin-rebuild switch`.

## Change Procedure

1. Inspect existing modules and documentation.
2. Consult official documentation.
3. Implement the smallest maintainable change.
4. Validate the affected host.
5. Update documentation when needed.
6. Review the Git diff.
7. Commit only when authorized.

## Additional Documentation

See `docs/architecture.md` and `docs/bootstrap/`.

OmniWM (macOS window manager and OmniShell bar) is documented in
`docs/omniwm.md`. Read it before changing anything related to OmniWM,
including `modules/darwin/omniwm.nix`, `home/xhan/darwin/omniwm.nix` and
`home/xhan/darwin/omniwm/`, and update it with those changes.
