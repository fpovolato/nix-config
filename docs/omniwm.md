# OmniWM

[OmniWM](https://omniwm.app/) is the tiling window manager on the MacBook
(`macbook` flake output, host name `nixmbp`). OmniShell, its built-in shell,
draws the bar and widgets. OmniWM requires macOS 26 or later on Apple Silicon.
It is not used on NixOS.

This file is the reference for anything OmniWM-related. Read it before
changing OmniWM, OmniShell, their files in this repository, or macOS settings
that interact with them, and keep it up to date with such changes.

## Files

| Path | Purpose |
| --- | --- |
| `modules/darwin/omniwm.nix` | nix-darwin: Homebrew cask, Spaces setting, launchd agent |
| `home/xhan/darwin/omniwm.nix` | Home Manager: config links, macOS hotkey conflict fix |
| `home/xhan/darwin/omniwm/settings.toml` | OmniWM settings, linked from `~/.config/omniwm/settings.toml` |
| `home/xhan/darwin/omniwm/shell/` | OmniShell folder, linked from `~/.config/omniwm/shell` |
| `home/xhan/darwin/omniwm/shell/.gitignore` | Allowlist of the OmniShell files tracked by Git |
| `modules/darwin/homebrew.nix` | Homebrew cleanup policy that affects switching casks |

Runtime state that is not versioned:

- `~/.local/state/omniwm/`: clipboard history, window restore catalog and
  other volatile state.
- `~/Library/Logs/omniwm.log`, `~/Library/Logs/omniwm.err.log`: launchd agent
  output.
- `~/.config/omniwm/settings.toml.pre-v5` (and similar): backups written by
  OmniWM before a schema upgrade.

## How It Is Wired

### Installation

`modules/darwin/omniwm.nix` installs the `omniwm@canary` Homebrew cask, as
required by the macOS package policy in `AGENTS.md`. It provides
`/Applications/OmniWM.app` and links `omniwmctl` into `/opt/homebrew/bin`.

Canary builds are signed and notarized daily builds of upstream `main`; they
may contain regressions. They are used because OmniShell is not in a stable
release yet. The stable cask is `omniwm`; both install the same app with the
bundle ID `com.barut.OmniWM`, so macOS permissions carry over between them.

Do not use Home Manager's `programs.omniwm` module or the Nixpkgs `omniwm`
package: they exist only on unstable branches (not on the pinned 26.05
releases) and would install a Nix copy of the app.

### macOS Settings

- `system.defaults.spaces.spans-displays = false` keeps "Displays have
  separate Spaces" on, the macOS default. OmniWM pauses window management
  without it. Use one native Space per display and OmniWM workspaces instead.
- OmniWM's Command Palette uses Control+Option+Space, which macOS also binds
  to "Select next source in Input menu" (symbolic hotkey 61). The Home Manager
  activation step `disableNextInputSourceHotkey` disables only that entry with
  `defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add`,
  so other symbolic hotkeys are preserved, then reloads them with
  `activateSettings -u`. Control+Space (hotkey 60) still switches between the
  Italian - Pro and ABC layouts. Re-enabling the macOS shortcut in System
  Settings lasts only until the next activation.

### Startup

A launchd user agent, `org.nixos.omniwm`, runs
`/Applications/OmniWM.app/Contents/MacOS/OmniWM` at login. `KeepAlive` has
`SuccessfulExit = false`: it restarts OmniWM after a crash, not after Quit.
OmniWM's own "Start at Login" setting must stay off, or two instances start.

After an install or activation, the agent-started process has been observed
to exit with code 0, which launchd does not restart. If OmniWM is not running,
start it through the agent:

```bash
launchctl kickstart gui/$(id -u)/org.nixos.omniwm
```

### Settings File

`~/.config/omniwm/settings.toml` is a Home Manager out-of-store symlink
(`mkOutOfStoreSymlink`) to `home/xhan/darwin/omniwm/settings.toml` in the
working tree at `~/nix-config`, not to a Nix store copy. OmniWM writes
through symlinks and live-reloads the file, so:

- changes made in OmniWM's Settings window land in the repository and show
  up in `git diff`;
- changes made by editing the repository file apply immediately, without
  activation.

The file's contents are therefore not pinned by `flake.lock`; only the link
is. `force = true` lets Home Manager replace a regular file OmniWM wrote
before the link existed. The link is created only while the repository file
exists in the flake source, i.e. is tracked by Git (`builtins.pathExists`).

### OmniShell Folder

`~/.config/omniwm/shell` is an out-of-store symlink to
`home/xhan/darwin/omniwm/shell/`. The whole directory is linked, rather than
individual files, so OmniWM can create and atomically replace files in it.

OmniWM installs and updates `default/`, the bundled styles (`wayline`,
`nocturne`, `lake`, `celestial`, `matrix`, `sakura`) and `omniwm.d.luau`
there on every release. The folder's `.gitignore` is an allowlist: only
`.gitignore`, `shell.toml` and `widgets/` are tracked. The folder stays
mostly empty until OmniShell is used, for example by enabling the Workspace
Bar and choosing a style in Settings > Styles & Widgets.

## Making Changes

### OmniWM Settings

- Prefer the Settings window. It always writes a complete, valid file.
- The schema is strict. In a `schemaVersion = 5` file, a missing required
  key, an unknown or duplicate hotkey action, an invalid enum value or
  conflicting gesture finger counts reject the whole file, and OmniWM keeps
  its previous settings (or defaults at startup) and shows a notice. Change
  values in place; do not delete keys. Check every key against the
  [settings reference](https://omniwm.app/config/settings-reference/).
- Do not add comments: OmniWM removes them when it rewrites the file, and it
  may reorder keys.
- Hotkeys are `[[hotkeys]]` entries with `id` and `binding`; each `id`
  appears once and `binding = "Unassigned"` disables one. When choosing a
  binding, check it against macOS shortcuts (see the hotkey 61 case above).
- No activation is needed. Review with `git diff` and commit.
- Settings that are not stored in this file: Start at Login and System-wide
  Window Corners, both managed by macOS.

Check that the file still parses as TOML (this does not check the schema;
OmniWM's notice and Diagnostics do):

```bash
nix eval --impure --expr 'builtins.typeOf (builtins.fromTOML (builtins.readFile ./home/xhan/darwin/omniwm/settings.toml))'
```

### OmniShell

- Bar layout, style, palette and widget options live in `shell.toml`. The
  Settings window writes it too.
- Own widgets go in `widgets/`, which takes precedence over the profiles.
- To customize a bundled widget, eject it first (Settings > Advanced > Shell
  Development > Edit Widget Source…, or `omniwmctl shell eject <widget>`),
  which copies it into `widgets/`. Never edit `default/` or the bundled styles:
  OmniWM replaces them on upgrade and they are not tracked.
- To version a profile of your own, create a folder next to `shell.toml` and
  add `!/<profile>/` to the `.gitignore`.
- See the [OmniShell guides](https://omniwm.app/omnishell/configuration/profiles-palettes/)
  and the Luau API reference on the OmniWM website.

### Nix Configuration

Changes to `modules/darwin/omniwm.nix` or `home/xhan/darwin/omniwm.nix`
require activation. Validate with the commands in `AGENTS.md`, and never
activate without explicit authorization.

## Operations

### First Launch

macOS privacy permissions cannot be declared. On first launch grant
Accessibility and Input Monitoring (required) and optionally Screen Recording
(Overview thumbnails and other captured visuals), then click Start OmniWM.

### Upgrading

Quit OmniWM before upgrading: Homebrew replaces the app bundle underneath a
running instance. This includes the Fish `update` alias, which runs
`brew upgrade --greedy`. Activation itself does not upgrade
(`homebrew.onActivation.upgrade = false`).

```bash
brew upgrade --cask omniwm@canary
```

OmniWM's update check only notifies; it never downloads or installs.

### Schema Upgrades

A new OmniWM version may upgrade `settings.toml` to a newer schema. It backs
up the original next to `~/.config/omniwm/settings.toml` (for example
`settings.toml.pre-v5`), then rewrites the file through the link, so the
upgrade shows up in `git diff`; commit it. The 0.7.6 stable release wrote
`schemaVersion = 4`; the first canary launch upgraded it to 5.

### Switching Between Canary and Stable

Both casks install `OmniWM.app` and conflict. Homebrew cleanup
(`cleanup = "uninstall"`) removes undeclared casks only after every declared
package installed successfully, and the new cask cannot install while the
old one is present, so remove the old one by hand:

1. Change the cask in `modules/darwin/omniwm.nix`.
2. Quit OmniWM.
3. Run `brew uninstall --cask omniwm@canary` (or `omniwm` when going to
   canary).
4. Activate.

Stable may be unable to read settings saved by canary. Restore a committed
version of `settings.toml` with `git restore` if needed. OmniShell exists only
in canary for now.

Never use `homebrew.onActivation.cleanup = "zap"`: zapping a removed OmniWM
cask trashes `~/.config/omniwm`, including the links into this repository.

### Recreating the Settings File

If `home/xhan/darwin/omniwm/settings.toml` is ever lost, do not write it by
hand. Remove it from Git and activate (the link is then not created), launch
OmniWM, choose Reveal Settings File from its menu bar icon to make it write a
complete canonical file, copy that file back into the repository, `git add`
it and activate again.

## References

- [Installation](https://omniwm.app/guides/install/)
- [Configuration](https://omniwm.app/config/configuration/)
- [Settings reference](https://omniwm.app/config/settings-reference/)
- [App rules](https://omniwm.app/features/app-rules/)
- [Workspace bar](https://omniwm.app/features/workspace-bar/)
- [OmniShell profiles and palettes](https://omniwm.app/omnishell/configuration/profiles-palettes/)
- [OmniShell bars, popouts and drawers](https://omniwm.app/omnishell/configuration/bars-drawers/)
- [CLI and IPC](https://omniwm.app/reference/cli/overview/)

The online documentation follows upstream `main`; features marked Unreleased
are available in canary builds only.
