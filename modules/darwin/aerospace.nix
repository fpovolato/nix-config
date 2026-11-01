# AeroSpace system configuration. See docs/aerospace.md before changing it.
{ ... }:

{
  # AeroSpace tiling window manager, from its official tap. The cask also
  # links the `aerospace` CLI into /opt/homebrew/bin. AeroSpace starts itself
  # at login (`start-at-login` in its config), so no launchd agent is needed.
  homebrew = {
    taps = [ "nikitabobko/tap" ];
    casks = [ "nikitabobko/tap/aerospace" ];
  };

  # AeroSpace recommends turning "Displays have separate Spaces" off: macOS is
  # more stable with AeroSpace that way. Takes effect after logging out.
  system.defaults.spaces.spans-displays = true;

  # Mission Control shows AeroSpace's hidden windows too small unless windows
  # are grouped by application.
  system.defaults.dock.expose-group-apps = true;
}
