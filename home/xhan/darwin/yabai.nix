# yabai, skhd.zig and SketchyBar user configuration.
# See docs/yabai.md before changing it.
{ ... }:

{
  # All three programs are installed through Homebrew; Home Manager only places
  # their configuration. Restart the services after activation to apply it.
  xdg.configFile."yabai/yabairc" = {
    source = ./yabai/yabairc;
    executable = true;
  };

  xdg.configFile."skhd/skhdrc".source = ./yabai/skhdrc;

  # Links each file, keeping its executable bit: SketchyBar runs sketchybarrc
  # and the plugins directly.
  xdg.configFile."sketchybar" = {
    source = ./sketchybar;
    recursive = true;
  };
}
