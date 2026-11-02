{ ... }:

# Quickshell draws the status bar from the QML files in ./quickshell,
# installed as ~/.config/quickshell/bar. It runs as a user service started
# with the Hyprland session.
{
  programs.quickshell = {
    enable = true;

    configs.bar = ./quickshell;
    activeConfig = "bar";

    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
  };
}
