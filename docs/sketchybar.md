# SketchyBar

[SketchyBar](https://felixkratz.github.io/SketchyBar/) is a candidate status
bar for the MacBook, kept alongside OmniWM's own bar (OmniShell) until one of
them is chosen. Read this file before changing SketchyBar or its files in
this repository, and update it with those changes.

## Files

| Path | Purpose |
| --- | --- |
| `modules/darwin/sketchybar.nix` | nix-darwin: Homebrew tap and formula |
| `home/xhan/darwin/sketchybar.nix` | Home Manager: links the configuration |
| `home/xhan/darwin/sketchybar/` | `sketchybarrc` and plugins, linked file by file into `~/.config/sketchybar/` |

The files are Nix store copies: changes apply after a rebuild and
`sketchybar --reload`.

## Installation and Startup

The formula is `FelixKratz/formulae/sketchybar`; the tap is declared in
`homebrew.taps`, so `cleanup = "uninstall"` keeps it.

SketchyBar is **not started at login**. OmniWM's Workspace Bar sits at the
top of the screen over the menu bar (`position = "overlappingMenuBar"`), and
SketchyBar would draw in the same place. To try it, turn off OmniWM's
Workspace Bar in its settings, then run:

```sh
sketchybar
```

in a terminal (it stops with the terminal), or `brew services start
sketchybar` to keep it running and start it at login, undone with
`brew services stop sketchybar`. If SketchyBar is chosen, declare a launchd
agent in `modules/darwin/sketchybar.nix` instead of `brew services`, and
decide how the macOS menu bar and OmniWM's bar are hidden. Do not declare
`_HIHideMenuBar` while OmniWM's bar is enabled: OmniWM manages that setting
(see [omniwm.md](omniwm.md)).

## Items

The bar is 32 points high, at the top, in Catppuccin Mocha with JetBrains
Mono Nerd Font (installed as a cask in `modules/darwin/homebrew.nix`). Left:
the focused app. Right: battery, Wi-Fi, volume and clock. Each item's script
is in `home/xhan/darwin/sketchybar/plugins/`; keep them executable (`git`
tracks the mode, and Home Manager keeps it).

- Wi-Fi: the icon is dimmed while the Wi-Fi interface has no IP address. The
  network name is shown only when macOS reveals it; since macOS 15 it hides
  the SSID from apps without Location Services access, so usually only the
  icon shows. A click opens Wi-Fi settings.
- Icons are Nerd Font glyphs written as characters in the scripts.
- There are no workspace items: OmniWM's workspaces are not macOS Spaces.

## History

yabai, skhd.zig and SketchyBar replaced OmniWM briefly and were reverted:
on macOS 27, yabai's scripting addition (needed to switch Spaces) does not
work, and forwarding the hotkeys to macOS's own Desktop shortcuts did not
work either. Only SketchyBar was kept.

## Official References

- [SketchyBar setup](https://felixkratz.github.io/SketchyBar/setup)
- [Items and properties](https://felixkratz.github.io/SketchyBar/config/items)
- [Events](https://felixkratz.github.io/SketchyBar/config/events)
