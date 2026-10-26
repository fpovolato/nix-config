# MacBook Bootstrap

## Overview

This document describes how to bootstrap the MacBook Pro M2
from a clean macOS installation.

This guide uses the original `xhan` account and `macbook` flake output.
For a different account, hostname or output, follow the
[README installation guide](../../README.md#install-on-another-mac) first.

The MacBook uses Nix for declarative system configuration,
Homebrew for application installation, and Home Manager
for user configuration.

## Target System

| Property | Value |
|---|---|
| Hardware | MacBook Pro M2 |
| Architecture | aarch64-darwin |
| Operating system | macOS |
| User | xhan |
| Flake output | macbook |
| Nix implementation | Upstream Nix |
| System management | nix-darwin |
| Package management | Homebrew |
| Homebrew installation | nix-homebrew |
| User configuration | Home Manager |

## 1. Prepare macOS

Before installing Nix:

1. Update macOS.
2. Enable FileVault.
3. Install Apple Command Line Tools.

Verify the developer tools:

```sh
xcode-select -p
git --version
```

If Command Line Tools are missing:

```sh
xcode-select --install
```

## 2. Install Nix

Use the NixOS Community installer for upstream Nix.

The installation should:

- Use multi-user mode.
- Enable Flakes.
- Create a dedicated encrypted APFS volume.
- Configure the Nix daemon through launchd.

Installation command:

```sh
curl -sSfL https://artifacts.nixos.org/nix-installer \
  | sh -s -- install macos --enable-flakes --encrypt true --explain
```

Review the installation plan before confirming.

The plan should explicitly indicate an encrypted APFS
volume named `Nix Store`.

After installation, open a new terminal.

Verify Nix:

```sh
nix --version
nix config show experimental-features
nix store info
```

Expected experimental features include:

- nix-command
- flakes

## 3. Configure GitHub SSH

Create a dedicated SSH key for GitHub.

```sh
mkdir -p ~/.ssh
chmod 700 ~/.ssh

ssh-keygen -t ed25519 -a 100 \
  -C "xhan@macbook-github" \
  -f ~/.ssh/id_ed25519_github
```

Protect the key with a passphrase.

Create the SSH configuration:

```sh
cat > ~/.ssh/config <<'SSH_CONFIG'
Host github.com
    HostName github.com
    User git
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
SSH_CONFIG

chmod 600 ~/.ssh/config
```

Register the private key passphrase in macOS Keychain:

```sh
/usr/bin/ssh-add --apple-use-keychain \
  ~/.ssh/id_ed25519_github
```

Copy the public key:

```sh
pbcopy < ~/.ssh/id_ed25519_github.pub
```

Add it to GitHub as an authentication key:

https://github.com/settings/keys

Verify SSH authentication:

```sh
ssh -T git@github.com
```

Verify GitHub's official SSH host fingerprint before
accepting the first connection.

Never upload or share the private key.

## 4. Clone the Configuration Repository

```sh
cd ~

git clone git@github.com:fpovolato/nix-config.git

cd nix-config
```

Verify the repository:

```sh
git status --short
git branch --show-current
git log -1 --oneline
```

The working tree should be clean.

If the repository is private, authenticate with GitHub before cloning.

## 5. Validate nix-darwin

Evaluate the macOS configuration:

```sh
nix eval --raw \
  '.#darwinConfigurations.macbook.config.system.build.toplevel.drvPath'
```

Build without activating:

```sh
nix build \
  '.#darwinConfigurations.macbook.system' \
  --no-link \
  --print-out-paths
```

Both commands must complete successfully.

## 6. Bootstrap nix-darwin

For the first installation:

```sh
sudo "$(nix build '.#darwinConfigurations.macbook.system' --no-link --print-out-paths)/sw/bin/darwin-rebuild" \
  switch --flake "$HOME/nix-config#macbook"
```

The initial activation configures:

- nix-darwin
- nix-homebrew
- Homebrew under /opt/homebrew
- Homebrew formulas and casks
- Home Manager
- Shared user configuration

Do not install Homebrew manually beforehand.

The existing upstream Nix installation is preserved
using the nix-darwin option:

```nix
nix.enable = false;
```

This means nix-darwin does not manage the Nix daemon.

## 7. Regular System Rebuilds

After the initial installation:

```sh
cd ~/nix-config

sudo darwin-rebuild switch --flake .#macbook
```

This applies the current declarative configuration.

After activating the configuration containing the abbreviation, open a new
Fish shell and type `bswitch`, then press Enter. It builds the configuration
first and activates it only if the build succeeds. It uses `~/nix-config`
and works from any directory.

Always validate changes before activation.

## 8. Verify Homebrew

Check the Homebrew installation:

```sh
brew --version
brew --prefix
```

The expected prefix on Apple Silicon is:

```text
/opt/homebrew
```

List installed packages:

```sh
brew list --formula
brew list --cask
```

Global CLI tools and GUI applications are installed
through Homebrew, not directly through Nixpkgs.

Their declarations belong in:

`modules/darwin/homebrew.nix`

## 9. Verify Home Manager

Verify Fish aliases:

```sh
fish -c 'alias'
```

Verify managed configuration files:

```sh
ls -l ~/.config/fish/conf.d/50-nix-aliases.fish
ls -l ~/.config/git/config
```

These files should be managed through Home Manager
and linked to the Nix Store.

The shared aliases are defined in:

`home/xhan/common/aliases.nix`

Home Manager configures Fish and Git without
installing separate copies of these programs.

## 10. Package Management Policy

On macOS:

- Install CLI tools through `homebrew.brews`.
- Install GUI applications through `homebrew.casks`.
- Manage Homebrew itself with nix-homebrew.
- Manage dotfiles with Home Manager.
- Avoid installing ordinary global applications
  through `home.packages`.
- Check for implicit Nixpkgs package installation
  when enabling Home Manager modules.

On NixOS:

- Use Nixpkgs for system and user packages.
- Use Home Manager for user packages and dotfiles.

Project-specific development environments may use
Nix Flakes and `nix develop`.

## 11. Secrets

A separate private repository named `nix-secrets` is pinned as an input.
It currently supplies the NixOS SSH public login key. Fetching the flake,
including on macOS, requires SSH access to that repository.

Agenix tooling and recipient rules are prepared in nix-secrets; runtime
decryption in nix-config is not yet integrated.

Never store plaintext secrets or private keys in
the configuration repository or Nix Store.

## 12. Troubleshooting

### Nix command not found

Open a new terminal and verify that the Nix
environment has been loaded.

### darwin-rebuild not found

Check whether the initial nix-darwin activation
completed successfully.

### Homebrew command not found

Verify that nix-homebrew was activated and that
Homebrew is available under `/opt/homebrew`.

### Home Manager activation conflict

Do not delete existing configuration files blindly.
Inspect conflicting paths before making changes.

### Git tree is dirty

This warning indicates uncommitted Git changes.
It does not necessarily mean the Nix evaluation failed.

## 13. Official References

- Nix: https://nix.dev/
- Nix installer: https://github.com/NixOS/nix-installer
- nix-darwin: https://github.com/nix-darwin/nix-darwin
- Home Manager: https://github.com/nix-community/home-manager
- nix-homebrew: https://github.com/zhaofengli/nix-homebrew
- Homebrew: https://docs.brew.sh/
- Fish: https://fishshell.com/docs/current/

## 14. Related Documentation

- `AGENTS.md`
- `docs/architecture.md`
- `hosts/macbook/default.nix`
- `modules/darwin/homebrew.nix`
- `modules/darwin/home-manager.nix`
- `home/xhan/darwin/default.nix`

Update this guide whenever the bootstrap procedure
or system architecture changes.
