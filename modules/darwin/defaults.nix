{ config, ... }:

{
  # Keep the Mac and its display awake when idle.
  power.sleep = {
    computer = "never";
    display = "never";
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # Preferences for the primary macOS user.
  system.defaults.controlcenter.BatteryShowPercentage = true;

  system.defaults.dock = {
    autohide = true;
    show-recents = false;

    # Finder and Trash are provided by macOS at either end of the Dock.
    persistent-apps = [
      "/Applications/Zen.app"
      "/Applications/Ghostty.app"
      "/System/Applications/System Settings.app"
      # Separate pinned apps from other running apps with a narrow gap.
      { spacer = { small = true; }; }
    ];

    persistent-others = [
      { folder = "${config.users.users.${config.system.primaryUser}.home}/Downloads"; }
    ];
  };
}
