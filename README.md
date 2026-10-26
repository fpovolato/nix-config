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
  <a href="#features">Features</a> ·
  <a href="#roadmap">Roadmap</a> ·
  <a href="#built-for-humans-and-coding-agents">Working with agents</a> ·
  <a href="#repository-layout">Structure</a> ·
  <a href="docs/architecture.md">Documentation</a> ·
  <a href="LICENSE">MIT license</a>
</p>

---

A personal Nix configuration for a Linux desktop and an Apple Silicon Mac.
Shared settings keep the essentials consistent, while dedicated platform
modules let each machine use its native tools.

**Designed to be maintained by humans and coding agents alike.** Clear module
boundaries, written instructions and repeatable checks make it straightforward
for an agent to understand the setup, change it and validate the result.

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

## Features

### Shared foundation

- [x] One flake for NixOS and macOS, with pinned Nix inputs.
- [x] Separate host, system and user modules, with shared Home Manager settings.
- [x] Ghostty with Catppuccin Mocha, a block cursor and a custom cursor trail.
- [x] Fish, Starship and shared command aliases.
- [x] `nil` and `nixd` language servers for editing Nix configuration.
- [x] Build-and-activate helpers and an explicit update workflow.
- [x] Agent instructions, architecture documentation and a Mac installation guide.

### macOS desktop

- [x] Homebrew applications managed through nix-darwin and nix-homebrew.
- [x] OmniWM tiling, workspace rules and an embedded Ghostty quake terminal.
- [x] OmniShell bar with a customized volume widget.
- [x] Declarative Dock, Finder, keyboard and default file association settings.
- [x] Custom wallpaper and fastfetch artwork.
- [x] Touch ID for sudo, idle screen saver and immediate password requirement.

### NixOS desktop

- [x] Hyprland with XWayland support.
- [x] Limine bootloader with a Windows boot entry.
- [x] Btrfs subvolumes with Zstd compression.
- [x] NetworkManager and SSH restricted to the configured user, with password
  and keyboard-interactive authentication disabled.

### Repository checks

- [x] Gitleaks hook for staged changes, enabled separately in each clone.
- [x] A script to scan current source files and locally reachable Git history.
- [x] GitHub Actions workflow for secret scanning on pushes and pull requests.
- [x] Documented evaluation and build commands before system activation.

## Roadmap

Unchecked items are not implemented. The planned work below is already
identified in the project documentation; the proposals are possible next steps,
with no fixed delivery schedule.

### Planned

- [x] Reference SSH public keys from the pinned private `nix-secrets` repository.
- [ ] Integrate agenix runtime decryption for credentials used by services.
- [ ] Define encryption recipients, key rotation and secret recovery procedures.

### Proposed next steps

- [ ] Centralize user, hostname and flake-output settings to simplify adoption
  on another machine.
- [ ] Add Nix evaluation and build checks to CI alongside secret scanning.
- [ ] Add a NixOS bootstrap guide covering hardware generation and disk layout.
- [ ] Support versioned custom OmniShell profiles, extending the existing
  copy-on-activation approach used for widgets.
- [ ] Document rollback and recovery for failed Nix activations and Homebrew
  upgrades, including their different recovery mechanisms.

Nix inputs are pinned in `flake.lock`. Homebrew application versions are not
fully reproducible from that lockfile. On macOS, Home Manager primarily manages
settings; `nil` and `nixd` are the documented Nix-installed tool exceptions.

> [!IMPORTANT]
> Adapt this configuration before activating it. Review the application list,
> Homebrew cleanup policy, keyboard shortcuts and account settings. The Mac
> setup targets **Apple Silicon with macOS 26 or later** because of OmniWM;
> Intel Macs are not validated here.

## Built for humans and coding agents

Agent-assisted maintenance is part of the design of this repository. You can
ask a coding agent to add applications, adjust desktop settings, maintain
shared dotfiles or adapt the configuration to another machine. The repository
provides the context and workflow for making those changes reviewable:

- **An explicit starting point:** [AGENTS.md](AGENTS.md) defines the architecture,
  package-management rules, validation commands and change procedure.
- **Predictable places to edit:** `hosts/`, `modules/` and `home/` separate
  machine definitions, platform settings and user configuration.
- **Documented decisions:** [the architecture guide](docs/architecture.md) and
  feature guides explain how the pieces fit together and what needs updating.
- **Verification before activation:** agents can evaluate the affected host,
  build the macOS configuration without activating it, scan for secrets and
  present the Git diff for review.

For example, a request can be as simple as:

> Read AGENTS.md, add a CLI tool to the Mac's Homebrew configuration, validate
> the macOS build and explain the diff. Do not activate the configuration.

System activation and commits require explicit authorization under the project
instructions. These are workflow rules, not a sandbox: configure the agent's
permissions separately. OmniWM's live-linked settings are an exception to the
usual build-and-activate workflow; editing them can affect the running app
immediately, as explained in [the OmniWM guide](docs/omniwm.md).

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

This private configuration also fetches `fpovolato/nix-secrets` over SSH.
You must have access to that repository to evaluate either host. If adapting
the setup for another account, change `inputs.nix-secrets.url` in `flake.nix`
to your own private repository with the same public-key path, then run
`nix flake update nix-secrets`. A copied configuration cannot use the
maintainer's private input without access.

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
The pinned `nix-secrets` input supplies `public-keys/ssh/macbook.pub`, which
authorizes the maintainer's key on Linux only. If you also adopt the Linux
configuration, use your own **public** key in your private input and review
Linux usernames and hardware configuration separately. Never copy a private
SSH key into either repository.

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
