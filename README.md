<p align="center">
  <img src="home/xhan/darwin/fastfetch/logo.png" alt="Nix snowflake with an Apple logo at its centre" width="200" />
</p>

<h1 align="center">nix-config</h1>

<p align="center">
  <strong>Two machines. One flake. A desktop that feels like home.</strong><br />
  NixOS &amp; macOS dotfiles, built around modular configuration and Catppuccin Mocha.
</p>

<p align="center">
  <a href="#install-on-another-mac">Install on macOS</a> ·
  <a href="#the-setup">The setup</a> ·
  <a href="#repository-layout">Structure</a> ·
  <a href="docs/architecture.md">Documentation</a> ·
  <a href="LICENSE">MIT license</a>
</p>

---

A personal Nix configuration for a Linux desktop and an Apple Silicon Mac.
Shared settings keep the essentials consistent, while dedicated platform
modules let each machine use its native tools.

## The setup

| | NixOS desktop | MacBook |
| --- | --- | --- |
| **System** | NixOS · `x86_64-linux` | nix-darwin · `aarch64-darwin` |
| **Window manager** | Hyprland | OmniWM + OmniShell |
| **Terminal** | Ghostty | Ghostty + embedded quake terminal |
| **Shell & prompt** | Fish + Starship | Fish + Starship |
| **Theme** | Catppuccin Mocha | Catppuccin Mocha |
| **Applications** | Nixpkgs | Homebrew via nix-homebrew |
| **User settings** | Home Manager | Home Manager |
| **Flake output** | `nixos` | `macbook` |
| **Account / hostname** | `xhan` / `nixos` | `xhan` / `nixmbp` |

### What’s inside

- **A shared terminal environment** — Ghostty, Fish, Starship, shell aliases
  and a custom cursor trail.
- **A tailored macOS desktop** — tiling, an OmniShell bar, workspace rules,
  wallpaper, Dock preferences and file associations.
- **Small, focused modules** — host definitions, system services and user
  settings live in separate layers.
- **Checks before changes** — build without activation, scan staged files
  with Gitleaks, and scan files and history in CI.

Nix inputs are pinned in `flake.lock`. Homebrew application versions are not
fully reproducible from that lockfile. On macOS, Home Manager primarily manages
settings; `nil` and `nixd` are the documented Nix-installed tool exceptions.

> [!IMPORTANT]
> Adapt this configuration before activating it. Review the application list,
> Homebrew cleanup policy, keyboard shortcuts and account settings. The Mac
> setup targets **Apple Silicon with macOS 26 or later** because of OmniWM;
> Intel Macs are not validated here.

## Repository layout

```text
.
├── flake.nix                 # Host outputs
├── flake.lock                # Pinned Nix inputs
├── hosts/
│   ├── nixos/                # Linux host and hardware
│   └── macbook/              # macOS host
├── modules/
│   ├── nixos/                # Linux system modules
│   └── darwin/               # macOS system modules
├── home/xhan/
│   ├── common/               # Shared user settings
│   ├── linux/                # Linux user settings
│   └── darwin/               # macOS user settings and artwork
├── docs/                     # Architecture and operational guides
├── keys/                     # Public SSH keys only
├── scripts/                  # Repository checks
├── .githooks/                # Staged-secret check
└── .github/workflows/        # Secret scanning in CI
```

## Install on another Mac

The commands below use macOS's default Zsh. Replace the example values with
your own. Keep the checkout at `~/nix-config`: shell helpers and OmniWM links
currently expect that location.

### 1. Prepare the Mac

1. Back up existing settings and enable FileVault in System Settings.
2. Create or use an existing administrator account. This configuration does
   **not** create or rename your macOS login account.
3. Install Apple's Command Line Tools:

   ```sh
   xcode-select --install
   ```

4. Identify the short login name and architecture:

   ```sh
   id -un
   uname -m
   ```

   Use the short name (for example `alice`), not the account's display name.
   The architecture should be `arm64`.

### 2. Install upstream Nix

Use the [NixOS Community installer](https://github.com/NixOS/nix-installer).
On a fresh Mac:

```sh
curl -sSfL https://artifacts.nixos.org/nix-installer \
  | sh -s -- install macos --enable-flakes --encrypt true --explain
```

Review the plan before accepting it; it should create an encrypted Nix Store
volume. Reopen the terminal, then check:

```sh
nix --version
nix config show experimental-features
nix store info
```

If Nix is already installed, inspect that installation instead of running a
second installer. This configuration sets `nix.enable = false`: the installer,
not nix-darwin, manages the daemon. Do not install Homebrew separately on a
fresh setup; nix-homebrew manages it. An existing Homebrew installation needs
review against the [nix-homebrew migration instructions](https://github.com/zhaofengli/nix-homebrew)
before activation.

### 3. Clone your fork

Fork this repository into your own account, then clone your fork:

```sh
git clone https://github.com/YOUR_ACCOUNT/nix-config.git ~/nix-config
cd ~/nix-config
```

If the repository is private, authenticate with GitHub first. Do not embed a
personal access token in the clone URL. SSH setup is documented in the
[MacBook bootstrap guide](docs/bootstrap/macbook.md#3-configure-github-ssh).

### 4. Change user and host

These are three independent identifiers:

| Identifier | Current value | Example replacement |
| --- | --- | --- |
| Existing macOS short username | `xhan` | `alice` |
| Computer / Bonjour / Unix hostname | `nixmbp` | `alice-mbp` |
| Flake output selected by rebuild commands | `macbook` | `laptop` |

For this example, make the following targeted edits. Do not perform a global
replacement: the repository also configures a separate Linux machine.

| File | Edit |
| --- | --- |
| `hosts/macbook/default.nix` | Set `system.primaryUser = "alice";` and `users.users.alice.home = "/Users/alice";`. Keep `aarch64-darwin`. |
| `modules/darwin/homebrew.nix` | Set `nix-homebrew.user = "alice";`. |
| `modules/darwin/home-manager.nix` | Change `users.xhan` to `users.alice`; keep the import path `../../home/xhan/darwin`. |
| `home/xhan/darwin/default.nix` | Set `home.username = "alice";` and `home.homeDirectory = "/Users/alice";`. |
| `modules/darwin/networking.nix` | Set all three names to `alice-mbp`. Use a simple hostname without spaces. |
| `flake.nix` | Optionally rename `darwinConfigurations.macbook` to `darwinConfigurations.laptop`. Keep `./hosts/macbook` as its module path. |
| `home/xhan/darwin/default.nix` | If renaming the output, change `darwinConfigurations.macbook.system` to `darwinConfigurations.laptop.system` in `buildCommand`, and `#macbook` to `#laptop` in `switchCommand`. |

The directories `hosts/macbook/` and `home/xhan/` are source paths, not account
names. Leave them as they are; renaming them also requires updating imports
and the source-tree paths in `home/xhan/darwin/omniwm.nix`.

Set your own Git identity too. To override the shared defaults **only on this
Mac**, add this at the top level of `home/xhan/darwin/default.nix` (which already
receives `lib`):

```nix
programs.git.settings.user = {
  name = lib.mkForce "YOUR_GIT_NAME";
  email = lib.mkForce "YOUR_VERIFIED_OR_NOREPLY_EMAIL";
};
```

Also configure the clone before making any commits; Home Manager has not been
activated yet:

```sh
git config --local user.name "YOUR_GIT_NAME"
git config --local user.email "YOUR_VERIFIED_OR_NOREPLY_EMAIL"
```

Changing the Mac configuration does not grant access to the NixOS host.
`keys/macbook.pub` authorizes the maintainer's key on Linux only. If you also
adopt the Linux configuration, replace it with your own **public** key and
review Linux usernames and hardware configuration separately. Never copy a
private SSH key into this repository.

### 5. Review what activation changes

- Edit `modules/darwin/homebrew.nix` for applications. Its
  `cleanup = "uninstall"` removes undeclared Homebrew formulae, casks and taps
  after successful installation. Declare anything you want to keep, or set
  cleanup to `"none"` before the first activation.
- `modules/darwin/defaults.nix` manages the Dock, Finder, keyboard mapping and
  idle sleep. Display sleep is five minutes and computer sleep fifteen minutes.
- Screen saver activation is five minutes; password requirement is immediate.
  Verify these settings in System Settings after activation.
- OmniWM is a canary build with Accessibility and Input Monitoring permissions.
  Read [docs/omniwm.md](docs/omniwm.md) before enabling or changing it.
- OmniWM's settings are live links into this checkout. Editing those files or
  checking out another revision can change the running app without a rebuild.
- Wallpaper and default file associations are applied by activation scripts.

### 6. Validate, then activate explicitly

The following commands use the renamed output `laptop`. If you kept the
original output, replace `laptop` with `macbook`.

Review changes. Add any newly created files by explicit path so the Git-backed
flake can see them; inspect staged content before committing:

```sh
git diff
git status --short
# For example, only if you created this file:
# git add path/to/new-file.nix
nix eval --raw '.#darwinConfigurations.laptop.config.system.build.toplevel.drvPath'
nix build '.#darwinConfigurations.laptop.system' --no-link
```

Only after both commands succeed, activate the **built, pinned** configuration:

```sh
sudo "$(nix build '.#darwinConfigurations.laptop.system' --no-link --print-out-paths)/sw/bin/darwin-rebuild" \
  switch --flake "$HOME/nix-config#laptop"
```

This first activation installs apps and changes macOS settings. It may take
time and request credentials. After activation, reopen the terminal, launch
OmniWM and grant its required permissions. Optional Screen Recording enables
captured visuals. Check:

```sh
command -v darwin-rebuild fish gitleaks nil nixd
brew --prefix
```

Homebrew should be under `/opt/homebrew`. If an existing config file conflicts
with Home Manager, back it up and inspect it before retrying; do not delete
unrelated settings blindly.

### 7. Enable local secret checks

For each clone, including the first one:

```sh
git config --local core.hooksPath .githooks
bash scripts/check-secrets.sh
```

The hook scans staged changes and blocks commits on findings or scanner errors.
It uses installed Gitleaks, or a project-scoped Nix environment before the
Homebrew package has been activated. On the first commit introducing the hook,
stage `.gitleaks.toml` with it: the hook reads its policy from the index.
See [SECURITY.md](SECURITY.md) for scan coverage and publication checks.

## Daily use

In an interactive Fish shell, `bswitch` expands to build and then activate the
configured host. `update` updates the flake and rebuilds; on macOS it also runs
`brew update` and `brew upgrade --greedy` before activation. Review changes
before using these commands. Earlier updates are not rolled back if a later
step fails. Quit OmniWM before upgrading its app bundle.

To validate the repository's original outputs without activation:

```sh
nix eval --raw '.#nixosConfigurations.nixos.config.system.build.toplevel.drvPath'
nix eval --raw '.#darwinConfigurations.macbook.config.system.build.toplevel.drvPath'
nix build '.#darwinConfigurations.macbook.system' --no-link
git diff --check
git diff --cached --check
```

Do not increase state versions as part of routine upgrades. The Linux hardware
file describes the maintainer's disks; do not reuse its UUIDs on another PC.

## Documentation and licenses

- [Architecture](docs/architecture.md)
- [Original MacBook bootstrap](docs/bootstrap/macbook.md)
- [OmniWM and live configuration](docs/omniwm.md)
- [Security and publication](SECURITY.md)
- [Agent instructions](AGENTS.md)

Original work is [MIT-licensed](LICENSE). Third-party files retain their own
licenses; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), including the
GPL-2.0-only OmniWM widget.

Official references: [Nix](https://nix.dev/),
[nix-darwin](https://nix-darwin.github.io/nix-darwin/manual/),
[Home Manager](https://nix-community.github.io/home-manager/),
[nix-homebrew](https://github.com/zhaofengli/nix-homebrew).
