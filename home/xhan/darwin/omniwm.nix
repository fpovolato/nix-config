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

  # ~/.config/omniwm/shell stays a real folder: OmniShell only lets widget
  # files physically inside it use `require`, so widgets cannot be links into
  # this repository. Only its settings file is linked, like settings.toml.
  home.file.".config/omniwm/shell/shell.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix-config/home/xhan/darwin/omniwm/shell/shell.toml";
    force = true;
  };

  # Earlier generations linked the whole folder into the repository. Remove
  # that link before linking shell.toml, or Home Manager would write through it.
  home.activation.unlinkOmniwmShellFolder = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
    if [ -L "$HOME/.config/omniwm/shell" ]; then
      run rm "$HOME/.config/omniwm/shell"
    fi
  '';

  # Copy the versioned widgets into the shell folder, replacing only the
  # widgets that exist in the repository.
  home.activation.copyOmniwmShellWidgets = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    widgets="$HOME/.config/omniwm/shell/widgets"
    run mkdir -p "$widgets"
    for widget in ${./omniwm/shell/widgets}/*/; do
      name="$(basename "$widget")"
      run rm -rf "$widgets/$name"
      run cp -R "''${widget%/}" "$widgets/$name"
      run chmod -R u+w "$widgets/$name"
    done
  '';

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
