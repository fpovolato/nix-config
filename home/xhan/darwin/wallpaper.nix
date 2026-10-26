{ lib, pkgs, ... }:

let
  wallpaper = ./wallpapers/nixos-wallpaper-catppuccin-mocha.png;
  setWallpaper = pkgs.writeText "set-wallpaper.js" ''
    ObjC.import('AppKit');

    function run(argv) {
      const url = $.NSURL.fileURLWithPath(argv[0]);
      const screens = $.NSScreen.screens;
      if (screens.count === 0) {
        throw new Error('No screens available; activate from a local graphical session.');
      }
      const workspace = $.NSWorkspace.sharedWorkspace;
      for (let i = 0; i < screens.count; i++) {
        const screen = screens.objectAtIndex(i);
        const error = Ref();
        if (!workspace.setDesktopImageURLForScreenOptionsError(
          url, screen, $.NSDictionary.dictionary, error
        )) {
          throw new Error(ObjC.unwrap(error[0].localizedDescription));
        }
      }
    }
  '';
in
{
  # Home Manager runs this as the user, after the dry-run boundary.
  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/osascript -l JavaScript ${setWallpaper} ${wallpaper}
  '';
}
