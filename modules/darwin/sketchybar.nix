# SketchyBar status bar. See docs/sketchybar.md before changing it.
{ ... }:

{
  # Installed and configured, but not started at login. Start it by hand to
  # try it (see docs/sketchybar.md).
  homebrew = {
    taps = [ "FelixKratz/formulae" ];
    brews = [ "FelixKratz/formulae/sketchybar" ];
  };
}
