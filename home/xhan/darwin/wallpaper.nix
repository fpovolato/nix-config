{ lib, pkgs, ... }:

let
  wallpaper = ./wallpapers/nixos-wallpaper-catppuccin-mocha.png;
  setWallpaper = pkgs.writeText "set-wallpaper.js" ''
    ObjC.import('AppKit');

    // Point every Idle (lock screen) entry of the wallpaper store at the image.
    // Linked entries share one choice between desktop and lock screen.
    function setIdleChoices(url) {
      const storePath = ObjC.unwrap($.NSHomeDirectory())
        + '/Library/Application Support/com.apple.wallpaper/Store/Index.plist';
      const data = $.NSData.dataWithContentsOfFile(storePath);
      if (data.isNil()) {
        return;
      }
      const store = $.NSPropertyListSerialization.propertyListWithDataOptionsFormatError(
        data, $.NSPropertyListMutableContainersAndLeaves, null, null
      );
      const configuration = $.NSPropertyListSerialization.dataWithPropertyListFormatOptionsError(
        $({ type: 'imageFile', url: { relative: ObjC.unwrap(url.absoluteString) } }),
        $.NSPropertyListBinaryFormat_v1_0, 0, null
      );

      function visit(dict) {
        const keys = dict.allKeys;
        for (let i = 0; i < keys.count; i++) {
          const key = keys.objectAtIndex(i);
          const value = dict.objectForKey(key);
          if (!value.isKindOfClass($.NSDictionary)) {
            continue;
          }
          if (['Idle', 'Linked'].includes(ObjC.unwrap(key))) {
            const choice = $.NSMutableDictionary.dictionary;
            choice.setObjectForKey(configuration, 'Configuration');
            choice.setObjectForKey($.NSArray.array, 'Files');
            choice.setObjectForKey('com.apple.wallpaper.choice.image', 'Provider');
            const content = $.NSMutableDictionary.dictionary;
            content.setObjectForKey($.NSArray.arrayWithObject(choice), 'Choices');
            content.setObjectForKey('$null', 'EncodedOptionValues');
            content.setObjectForKey('$null', 'Shuffle');
            value.setObjectForKey(content, 'Content');
            value.setObjectForKey($.NSDate.date, 'LastSet');
          } else {
            visit(value);
          }
        }
      }

      visit(store);
      const output = $.NSPropertyListSerialization.dataWithPropertyListFormatOptionsError(
        store, $.NSPropertyListBinaryFormat_v1_0, 0, null
      );
      if (!output.writeToFileAtomically(storePath, true)) {
        throw new Error('Unable to write ' + storePath);
      }
    }

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

      // Let WallpaperAgent persist the desktop change before editing its store.
      delay(1);
      setIdleChoices(url);
    }
  '';
in
{
  # Home Manager runs this as the user, after the dry-run boundary.
  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/osascript -l JavaScript ${setWallpaper} ${wallpaper}

    # Reload the edited wallpaper store so the lock screen picks it up.
    run /usr/bin/killall WallpaperAgent || true

    # Login window image shown before the user session is unlocked.
    userUuid="$(/usr/bin/dscl . -read "/Users/$(/usr/bin/id -un)" GeneratedUID | /usr/bin/awk '{ print $2 }')"
    lockscreenDir="/Library/Caches/Desktop Pictures/$userUuid"
    if [ -d "$lockscreenDir" ] && [ -w "$lockscreenDir" ]; then
      run /usr/bin/install -m 0640 ${wallpaper} "$lockscreenDir/lockscreen.png"
    fi
  '';
}
