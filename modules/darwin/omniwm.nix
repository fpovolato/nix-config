# OmniWM system configuration. See docs/omniwm.md before changing it.
{ config, ... }:

let
  home = config.users.users.${config.system.primaryUser}.home;
in
{
  # OmniWM tiling window manager, installed as a Homebrew cask.
  # The cask also links `omniwmctl` into /opt/homebrew/bin.
  # Canary (daily builds of main) is needed for OmniShell, which is not in a
  # stable release yet. It conflicts with the stable `omniwm` cask; Homebrew
  # cleanup runs only after a successful install, so remove the other cask by
  # hand before switching.
  homebrew.casks = [ "omniwm@canary" ];

  # OmniWM pauses window management unless each display has its own Spaces.
  # This is the macOS default; it is declared here to keep it that way.
  system.defaults.spaces.spans-displays = false;

  # Start OmniWM at login. Restart it after a crash, but not after Quit.
  launchd.user.agents.omniwm.serviceConfig = {
    Program = "/Applications/OmniWM.app/Contents/MacOS/OmniWM";
    RunAtLoad = true;
    KeepAlive.SuccessfulExit = false;
    ProcessType = "Interactive";
    StandardOutPath = "${home}/Library/Logs/omniwm.log";
    StandardErrorPath = "${home}/Library/Logs/omniwm.err.log";
  };
}
