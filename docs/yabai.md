# yabai, skhd.zig and SketchyBar

[yabai](https://github.com/asmvik/yabai) is the tiling window manager on the
MacBook (`macbook` flake output, host name `nixmbp`).
[skhd.zig](https://github.com/jackielii/skhd.zig) binds its hotkeys and
[SketchyBar](https://felixkratz.github.io/SketchyBar/) draws the status bar.
Read this file before changing any of them or their files in this
repository, and update it with those changes.

## Why yabai

OmniWM was removed because its hotkeys use Option, which DaVinci Resolve also
uses for most of its shortcuts, and OmniWM could only pause all hotkeys by
hand. Here the hotkeys belong to skhd, whose `.blacklist` stops it from
intercepting any key while Resolve is focused, and a yabai rule with
`manage=off` leaves Resolve's windows untouched.

## Files

| Path | Purpose |
| --- | --- |
| `modules/darwin/yabai.nix` | nix-darwin: Homebrew packages, Spaces and menu bar settings, scripting addition sudoers rule, SketchyBar agent |
| `home/xhan/darwin/yabai.nix` | Home Manager: links the configuration files |
| `home/xhan/darwin/yabai/yabairc` | yabai settings and rules, linked to `~/.config/yabai/yabairc` |
| `home/xhan/darwin/yabai/skhdrc` | skhd hotkeys and blacklist, linked to `~/.config/skhd/skhdrc` |
| `home/xhan/darwin/sketchybar/` | SketchyBar configuration and plugins, linked file by file into `~/.config/sketchybar/` |

The configuration files are Nix store copies: changes apply after a rebuild
and a service restart, not live.

## Installation

- yabai: formula `asmvik/formulae/yabai` (the project moved from
  `koekeishiya` to `asmvik`).
- skhd.zig: cask `jackielii/tap/skhd-zig`, which installs
  `/Applications/skhd.app` and links `skhd` into `/opt/homebrew/bin`. The
  original skhd is in maintenance mode and points to skhd.zig as its
  successor; the configuration format is the same.
- SketchyBar: formula `FelixKratz/formulae/sketchybar`.

All taps are declared in `homebrew.taps`, so `cleanup = "uninstall"` keeps
them.

## Scripting Addition and SIP

Focusing Spaces (Option + 1–9) and other commands (creating, destroying or
moving Spaces, `sticky`, `opacity`, `sub-layer`, window shadows and
animations) need yabai's scripting addition, which is injected into the Dock
and requires SIP to be **partially disabled**. This is done by hand, from
macOS Recovery (hold the power button until "Loading startup options", then
Options → Utilities → Terminal):

```sh
csrutil enable --without fs --without debug --without nvram
```

Restart into macOS, then:

```sh
sudo nvram boot-args=-arm64e_preview_abi
```

and restart again. `csrutil status` may report `unknown` with SIP partially
disabled. Apple repairs re-enable SIP; repeat the steps afterwards. To undo,
run `csrutil enable` from Recovery and `sudo nvram -d boot-args`.

`yabairc` runs `sudo yabai --load-sa` at startup and again whenever the Dock
restarts. The password-less sudoers rule it needs,
`/private/etc/sudoers.d/yabai`, is written by a nix-darwin activation step
(`postActivation` in `modules/darwin/yabai.nix`). It allows only
`/opt/homebrew/bin/yabai --load-sa`, pinned to the binary's SHA-256, so a
different binary at that path is refused. The step runs after the Homebrew
bundle on every activation, so the hash follows yabai upgrades made through
`update` or `bswitch`. After a `brew upgrade` outside activation, run
`bswitch` (or the activation) before restarting yabai, or loading fails.
The rule is checked with `visudo -c` before it is installed. Removing yabai
from the configuration does not delete the file; remove it by hand.

The activation step trusts whatever binary is at that path when it runs:
activate only after reviewing what Homebrew installed.

Without the scripting addition, everything else (tiling, rules, moving
windows to a Space) still works.

`modules/darwin/yabai.nix` also declares the Mission Control settings yabai
expects: "Displays have separate Spaces" on (`spans-displays = false`) and
"Automatically rearrange Spaces based on most recent use" off
(`mru-spaces = false`).

## Services

Both programs install and manage their own launchd agents; nix-darwin does
not declare them, because the skhd.zig cask restarts its own agent
(`com.jackielii.skhd`) on upgrade. After the first activation, once:

```sh
yabai --start-service
skhd --start-service
```

SketchyBar needs no manual start: nix-darwin declares a launchd user agent,
`org.nixos.sketchybar`, that starts it at login and restarts it if it exits.
Do not also use `brew services start sketchybar`, or two bars run. Its logs
are `~/Library/Logs/sketchybar.log` and `sketchybar.err.log`.

yabai and skhd each ask for Accessibility permission (skhd.zig may also ask for Input
Monitoring). Grant it in System Settings → Privacy & Security, then run the
same command again. The agents start at login afterwards. Logs are in
`/tmp/yabai_$USER.out.log`, `/tmp/yabai_$USER.err.log` and
`~/Library/Logs/skhd.log`; `skhd --status` checks skhd.

The yabai permission is tied to its binary: after `brew upgrade` changes it,
macOS may ask again. Remove the old entry and grant it again.

After changing a configuration file and rebuilding:

```sh
yabai --restart-service
skhd --restart-service
sketchybar --reload
```

## DaVinci Resolve

- `yabairc`: `app="^(DaVinci )?Resolve$" manage=off`. yabai neither tiles nor
  moves Resolve's windows.
- `skhdrc`: `.blacklist` lists `"davinci resolve"` and `"resolve"`. While
  Resolve is focused, skhd lets every key through, so Option shortcuts reach
  Resolve and none of the window hotkeys work.

Both match on the process name. If Resolve is still tiled or loses
shortcuts, check the name it reports while focused:

```sh
yabai -m query --windows --window | jq -r .app
```

and adjust both files. Add other apps with conflicting shortcuts the same way.

## Hotkeys

| Keys | Action |
| --- | --- |
| Option + arrows | Focus the window in that direction |
| Option + Tab | Focus the previously focused window |
| Option + Shift + arrows | Swap with the window in that direction |
| Option + 1–9 | Focus Space 1–9 |
| Control + Option + Tab | Focus the previously focused Space |
| Option + Shift + 1–9 | Move the window to Space 1–9 |
| Option + Return | Toggle zoom to full screen |
| Option + Shift + F | Toggle floating (centered) |
| Option + R | Rotate the layout by 90° |
| Option + 0 | Balance window sizes |
| Control + Command + Tab | Focus the next display |

Option + Left/Right also move by word in text fields; those keys are taken
by skhd outside blacklisted apps.

At startup `yabairc` creates Spaces (with `jq` counting the existing ones)
until there are nine in total, on the focused display. This needs the
scripting addition; without it, create them in Mission Control. yabai never
removes Spaces. Spotify and WhatsApp are sent to Spaces 8 and 9.

## SketchyBar

The bar is 32 points high, at the top of every display, in Catppuccin Mocha
with JetBrains Mono Nerd Font (installed as a cask in
`modules/darwin/homebrew.nix`). Left: Spaces 1–9 (the visible one
highlighted, click to focus it) and the focused app. Right: battery, volume
and clock. Each item's script is in `home/xhan/darwin/sketchybar/plugins/`;
keep them executable (`git` tracks the mode, and Home Manager keeps it).

- The bar height must equal the top value of `external_bar` in `yabairc`
  (`all:32:0`), so tiled windows start below it.
- `system.defaults.NSGlobalDomain._HIHideMenuBar = true` hides the macOS menu
  bar, which reappears when the pointer reaches the top of the screen. App
  menus (DaVinci Resolve's too) are still reached that way.
- Icons are Nerd Font glyphs written as characters in the scripts.

See the [SketchyBar documentation](https://felixkratz.github.io/SketchyBar/)
for items, events and properties.

## Official References

- [yabai wiki](https://github.com/asmvik/yabai/wiki)
- [yabai configuration](https://github.com/asmvik/yabai/wiki/Configuration)
- [yabai commands and rules](https://github.com/asmvik/yabai/wiki/Commands)
- [skhd.zig](https://github.com/jackielii/skhd.zig)
- [skhd.zig syntax](https://github.com/jackielii/skhd.zig/blob/main/SYNTAX.md)
- [Disabling SIP for yabai](https://github.com/asmvik/yabai/wiki/Disabling-System-Integrity-Protection)
- [SketchyBar setup](https://felixkratz.github.io/SketchyBar/setup)
