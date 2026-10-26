# OmniWM user configuration. See docs/omniwm.md before changing it.
{ config, lib, ... }:

let
  # Versioned OmniWM settings. OmniWM validates this file strictly, so it is
  # captured from the app's own canonical output instead of written by hand.
  settingsFile = ./omniwm/settings.toml;
in
{
  # Link to the working tree rather than the Nix store, so changes saved from
  # OmniWM's Settings window land in the repository and show up in `git diff`.
  # The link is only created once the file is tracked in the repository.
  home.file.".config/omniwm/settings.toml" = lib.mkIf (builtins.pathExists settingsFile) {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix-config/home/xhan/darwin/omniwm/settings.toml";
    # Replace the regular file OmniWM writes before the link exists.
    force = true;
  };

  # OmniShell folder (bar, widgets and styles), linked as a whole so OmniWM
  # can create and replace files inside it. Its .gitignore keeps the folders
  # OmniWM manages out of Git.
  home.file.".config/omniwm/shell".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/nix-config/home/xhan/darwin/omniwm/shell";

  # OmniWM's Command Palette uses Control+Option+Space, which macOS also binds
  # to "Select next source in Input menu" (symbolic hotkey 61). Disable only
  # that entry; Control+Space (hotkey 60) still switches input sources.
  # `-dict-add` leaves the other symbolic hotkeys untouched.
  home.activation.disableNextInputSourceHotkey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 \
      '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>786432</integer></array><key>type</key><string>standard</string></dict></dict>'

    # Apply the change without logging out.
    run /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
