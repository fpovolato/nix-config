# SketchyBar user configuration. See docs/sketchybar.md before changing it.
{ ... }:

{
  # Links each file, keeping its executable bit: SketchyBar runs sketchybarrc
  # and the plugins directly.
  xdg.configFile."sketchybar" = {
    source = ./sketchybar;
    recursive = true;
  };
}
