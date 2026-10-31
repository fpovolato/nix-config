# Raycast replaces Spotlight as the launcher. The app is installed by the
# Homebrew cask in modules/darwin/homebrew.nix; its own settings, including
# its hotkey, live in Raycast's database and are set in the app.
{ lib, ... }:

{
  # Free Command+Space for Raycast by disabling "Show Spotlight search"
  # (symbolic hotkey 64). Spotlight indexing and Command+Option+Space
  # (hotkey 65, Finder search window) are left untouched.
  # `-dict-add` leaves the other symbolic hotkeys untouched.
  home.activation.disableSpotlightHotkey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 \
      '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>'

    # Apply the change without logging out.
    run /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
