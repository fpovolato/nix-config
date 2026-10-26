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
- Host name: nixmbp
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
  percentage in the menu bar, Dock settings for the primary user, and
  the system-wide Caps Lock to Control keyboard mapping.
- `networking.nix`: the Mac's names. `computerName`, `localHostName`
  (Bonjour, `nixmbp.local`) and `hostName` are all `nixmbp`. The flake
  output stays `macbook`; rebuild commands name it explicitly, so they do
  not depend on the host name.
- `security.nix`: authentication settings, including Touch ID for `sudo`
  through `security.pam.services.sudo_local.touchIdAuth`.
- `homebrew.nix`: application installation.
- `home-manager.nix`: user configuration integration.

The Dock hides automatically and its pinned items are ordered as Finder,
Zen, Ghostty, System Settings, Downloads, and Trash. Finder and Trash are
fixed macOS items; the applications and Downloads are managed through
`persistent-apps` and `persistent-others`. Recent applications are enabled
with `show-recents = true` to display the native divider after pinned apps.
This section can include recently used apps that have already been closed;
it is not restricted to running apps. Pinned apps retain their positions
when running. No spacer tile is needed.
See [Apple's Dock guide](https://support.apple.com/en-gb/guide/mac-help/mh35859/mac).
These lists replace any manually pinned items at the next activation.

The MacBook stays awake with its display on during inactivity:
`modules/darwin/defaults.nix` sets `power.sleep.computer` and
`power.sleep.display` to `"never"`. Home Manager disables the primary user's
automatic screen saver through
`targets.darwin.currentHostDefaults."com.apple.screensaver".idleTime = 0`.
This applies on battery as well as external power, increasing battery use.
Manual locking and lid-close sleep are not disabled.
See the [nix-darwin power options](https://nix-darwin.github.io/nix-darwin/manual/#opt-power.sleep.display)
and [Apple's screen saver idle-time definition](https://developer.apple.com/documentation/devicemanagement/screensaveruser).

The macOS wallpaper is managed by `home/xhan/darwin/wallpaper.nix` through
a Home Manager activation step using macOS AppKit. The PNG is versioned in
`home/xhan/darwin/wallpapers/` and copied into the Nix store, so activation
does not depend on iCloud availability. It was imported from the user's
iCloud Wallpapers folder; later changes to that original are not synchronized.
Activation sets the wallpaper on currently connected screens in the user's
graphical session. Additional Spaces or screens connected later may require
another activation. Dry-run activation does not change the wallpaper.

The AppKit API only sets the desktop image, so the lock screen keeps the
macOS default. Activation therefore also rewrites the `Idle` and `Linked`
choices in `~/Library/Application Support/com.apple.wallpaper/Store/Index.plist`
to the same image and restarts `WallpaperAgent`. It also copies the image to
`/Library/Caches/Desktop Pictures/<user UUID>/lockscreen.png`, used by the
login window before unlocking. That store format is undocumented by Apple and
may change in future macOS releases; if it does, only the lock screen step
should be affected.

After activation, log out and back in if the menu bar has not refreshed.
Touch ID requires an enrolled fingerprint. To check it from a local terminal,
run `sudo -k` followed by `sudo -v`; password authentication remains available.

### Package Installation

NixOS uses Nixpkgs.

macOS uses Homebrew for global CLI and GUI applications.

The explicitly approved exception is `nil` and `nixd`: Home Manager installs
these Nix language servers from the pinned Nixpkgs on both hosts through
`home/xhan/common/nix-tools.nix`. On macOS, Fish adds the Home Manager profile
bin directory (`/etc/profiles/per-user/xhan/bin`) to PATH, including in login
and non-interactive shells. NixOS provides the user profile PATH through its
standard shell integration.

After activation, restart Zed and open a new shell. Check both servers with
`command -v nil nixd`. Zed's Nix extension uses the language servers from PATH;
Zed obtains the environment from the launching CLI or from a login shell
when launched graphically. See [Zed's environment documentation](https://zed.dev/docs/environment).

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

Ghostty uses the built-in `Catppuccin Mocha` theme on both hosts, declared
through Home Manager in `home/xhan/common/ghostty.nix`.

The cursor is a block. Ghostty's shell integration would otherwise switch it
to a bar at the prompt, so its `cursor` feature is disabled with
`shell-integration-features = no-cursor`; the other features keep their
defaults. Programs can still request another style with escape sequences.

An animated cursor trail is drawn by a custom shader,
`home/xhan/common/ghostty/cursor-trail.glsl`, loaded from the Nix store with
`custom-shader`. It uses Ghostty's cursor uniforms (`iCurrentCursor`,
`iPreviousCursor`, `iTimeCursorChange`; Ghostty 1.2 or later) and only shows
on moves longer than 1.5 line heights, so normal typing is not smeared.
Duration, distance threshold and opacity are constants at the top of the file.
Shader compile errors do not fail config validation; they appear only in
Ghostty's log, and the terminal then renders without the shader.

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

Public keys are not secrets and stay here. `keys/macbook.pub` is the public
half of the MacBook's `~/.ssh/id_ed25519` (comment `xhan@nixmbp`) and is
authorized for `xhan` on NixOS by `modules/nixos/ssh.nix`. The private key
never leaves the Mac.

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
