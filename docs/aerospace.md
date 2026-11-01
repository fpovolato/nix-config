# AeroSpace

[AeroSpace](https://nikitabobko.github.io/AeroSpace/guide) is the tiling
window manager on the MacBook (`macbook` flake output, host name `nixmbp`).
It replaced OmniWM. It is not used on NixOS.

Read this file before changing AeroSpace or its files in this repository, and
keep it up to date with such changes.

## Files

| Path | Purpose |
| --- | --- |
| `modules/darwin/aerospace.nix` | nix-darwin: Homebrew tap and cask, Spaces and Mission Control settings |
| `home/xhan/darwin/aerospace.nix` | Home Manager: links the config file |
| `home/xhan/darwin/aerospace/aerospace.toml` | AeroSpace config, linked to `~/.config/aerospace/aerospace.toml` |

## How It Is Wired

### Installation

The `nikitabobko/tap/aerospace` cask from AeroSpace's official tap provides
`/Applications/AeroSpace.app` and the `aerospace` CLI, as required by the
macOS package policy in `AGENTS.md`. The tap is declared in `homebrew.taps`,
so `cleanup = "uninstall"` keeps it.

Do not use Home Manager's `programs.aerospace` module: it installs a Nix copy
of the app. The config file is linked directly instead.

### Startup

`start-at-login = true` in `aerospace.toml` makes AeroSpace register itself
as a login item. No launchd agent is declared.

### macOS Settings

Declared in `modules/darwin/aerospace.nix`, following the
[AeroSpace guide](https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces):

- `system.defaults.spaces.spans-displays = true` turns "Displays have
  separate Spaces" **off**. AeroSpace is more stable that way. It takes effect
  after logging out. Trade-off: with a native fullscreen app on one monitor,
  the other monitor goes black.
- `system.defaults.dock.expose-group-apps = true` ("Group windows by
  application"), so Mission Control does not shrink AeroSpace's hidden windows.

Not declared, but recommended by the guide: leave free space in the
bottom-left or bottom-right corner of each monitor in the display arrangement,
where AeroSpace parks hidden windows. The Dock already auto-hides.

### Config File

`~/.config/aerospace/aerospace.toml` is a Home Manager link to a Nix store
copy of `home/xhan/darwin/aerospace/aerospace.toml`. Edit the repository file,
activate, then reload with `aerospace reload-config` (or Option+Shift+;
followed by Esc).

The file starts from AeroSpace's default config, with:

- 8 px inner and outer gaps;
- only the numbered workspaces 1–9 (the default letter workspaces are
  dropped);
- app rules: Spotify (`com.spotify.client`) → workspace 8, WhatsApp
  (`net.whatsapp.WhatsApp`) → workspace 9. They use the `if.app-id` form of
  `on-window-detected`, which the guide calls soft-deprecated but still
  supports; it can be rewritten with `if = 'test %{app-bundle-id} = …'` once
  the installed version is confirmed to accept it.

Find an app's bundle ID with
`defaults read /Applications/<App>.app/Contents/Info.plist CFBundleIdentifier`
or `aerospace list-apps`.

### Keys

| Keys | Action |
| --- | --- |
| Option+H/J/K/L | Focus left/down/up/right |
| Option+Shift+H/J/K/L | Move window |
| Option+1–9 | Switch workspace |
| Option+Shift+1–9 | Move window to workspace |
| Option+/ , Option+, | Tiles / accordion layout |
| Option+- , Option+= | Resize |
| Option+Tab | Previous workspace |
| Option+Shift+Tab | Move workspace to next monitor |
| Option+Shift+; | Service mode (Esc reload, R flatten, F float, Backspace close others) |

## Operations

### First Launch

macOS privacy permissions cannot be declared. On first launch grant
Accessibility to AeroSpace.

### Upgrading

`brew upgrade --cask nikitabobko/tap/aerospace`, or the Fish `update` alias
(`brew upgrade --greedy`). Activation itself does not upgrade.

### Leftovers From OmniWM

Removing OmniWM from the configuration does not undo everything it changed:

- Quit OmniWM before the first activation without it: activation removes
  its launchd agent and uninstalls the `omniwm@canary` cask
  (`cleanup = "uninstall"`) underneath a running instance. Afterwards
  `~/.config/omniwm`, `~/.local/state/omniwm` and `~/Library/Logs/omniwm*.log`
  stay. Delete them by hand if no longer wanted.
- The macOS shortcut "Select next source in Input menu"
  (Control+Option+Space, symbolic hotkey 61) stays disabled. Re-enable it in
  System Settings > Keyboard > Keyboard Shortcuts > Input Sources if wanted.
- OmniWM hid the native menu bar while its bar was on and restores the
  previous value when it quits normally. If the menu bar stays hidden, set
  "Automatically hide and show the menu bar" to Never in System Settings >
  Control Center.
- The embedded Ghostty quake terminal (Option+`) is gone. Ghostty's own
  quick terminal (`toggle_quick_terminal`) can replace it.

## References

- [Guide](https://nikitabobko.github.io/AeroSpace/guide)
- [Commands](https://nikitabobko.github.io/AeroSpace/commands)
- [Goodies](https://nikitabobko.github.io/AeroSpace/goodies)
