# yabai window manager, skhd.zig hotkey daemon and SketchyBar status bar.
# See docs/yabai.md before changing it.
{ config, lib, ... }:

let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  yabai = "/opt/homebrew/bin/yabai";
in
{
  homebrew = {
    taps = [
      "asmvik/formulae"
      "FelixKratz/formulae"
      "jackielii/tap"
    ];

    brews = [
      # yabai tiles windows. Its scripting addition needs SIP partially
      # disabled; see docs/yabai.md.
      "asmvik/formulae/yabai"
      "FelixKratz/formulae/sketchybar"
    ];

    # skhd.zig, the maintained successor of skhd, binds the hotkeys. It ships
    # as an app bundle so its Accessibility permission survives upgrades.
    casks = [ "jackielii/tap/skhd-zig" ];
  };

  # yabai requires each display to have its own Spaces (the macOS default),
  # and Spaces kept in a fixed order so rules and hotkeys find them.
  system.defaults.spaces.spans-displays = false;
  system.defaults.dock.mru-spaces = false;

  # SketchyBar replaces the menu bar, which shows only when the pointer
  # reaches the top of the screen.
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;

  # Let the primary user load the yabai scripting addition without a
  # password. The rule pins the binary's SHA-256, so it is regenerated on
  # every activation, after Homebrew has installed or upgraded yabai.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    if [ -x ${yabai} ]; then
      echo "Updating the yabai scripting addition sudoers rule..." >&2
      hash="$(/usr/bin/shasum -a 256 ${yabai} | /usr/bin/cut -d " " -f 1)"
      rule="${user} ALL=(root) NOPASSWD: sha256:$hash ${yabai} --load-sa"
      tmp="$(/usr/bin/mktemp)"
      printf '%s\n' "$rule" > "$tmp"
      if /usr/sbin/visudo -cqf "$tmp"; then
        /usr/bin/install -m 0440 -o root -g wheel "$tmp" /private/etc/sudoers.d/yabai
      else
        echo "warning: invalid yabai sudoers rule, leaving the old one in place" >&2
      fi
      /bin/rm -f "$tmp"
    fi
  '';

  # Start SketchyBar at login and restart it if it exits.
  launchd.user.agents.sketchybar.serviceConfig = {
    Program = "/opt/homebrew/bin/sketchybar";
    RunAtLoad = true;
    KeepAlive = true;
    ProcessType = "Interactive";
    # Plugins call sketchybar and yabai by name.
    EnvironmentVariables.PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
    StandardOutPath = "${home}/Library/Logs/sketchybar.log";
    StandardErrorPath = "${home}/Library/Logs/sketchybar.err.log";
  };
}
