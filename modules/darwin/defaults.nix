{ config, ... }:

{
  # Idle timeouts in minutes, on battery and external power.
  power.sleep = {
    computer = 15;
    display = 5;
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # Preferences for the primary macOS user.
  system.defaults.controlcenter.BatteryShowPercentage = true;

  # Show the current folder's path in Finder windows.
  system.defaults.finder = {
    ShowPathbar = true;
    _FXShowPosixPathInTitle = true;
  };

  system.defaults.dock = {
    autohide = true;
    # Use the native divider around the recent applications section.
    show-recents = true;

    # Finder and Trash are provided by macOS at either end of the Dock.
    persistent-apps = [
      "/Applications/Zen.app"
      "/Applications/Ghostty.app"
      "/System/Applications/System Settings.app"
    ];

    persistent-others = [
      { folder = "${config.users.users.${config.system.primaryUser}.home}/Downloads"; }
    ];
  };
}
