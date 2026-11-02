{ pkgs, ... }:

# Hyprland user configuration in Lua (Hyprland 0.55+). Home Manager writes
# ~/.config/hypr/hyprland.lua, which only loads the files in ./hyprland,
# installed as ~/.config/hypr/conf. Hyprland adds ~/.config/hypr to the Lua
# module path, so require("conf.keybinds") loads conf/keybinds.lua.
{
  wayland.windowManager.hyprland = {
    enable = true;

    # Hyprland and its portal are installed by programs.hyprland in
    # modules/nixos/hyprland.nix.
    package = null;
    portalPackage = null;

    configType = "lua";

    # Hyprland activates hyprland-session.target (bound to
    # graphical-session.target) at startup; hyprpaper, Quickshell, Vicinae and
    # the other session services start from it instead of exec-once.
    systemd.enable = true;

    extraConfig = ''
      require("conf.env")
      require("conf.monitors")
      require("conf.workspaces")
      require("conf.input")
      require("conf.appearance")
      require("conf.windowrules")
      require("conf.keybinds")
    '';
  };

  xdg.configFile."hypr/conf".source = ./hyprland;

  # Programs used by the key bindings.
  home.packages = with pkgs; [
    grim
    nautilus
    playerctl
    pwvucontrol
    slurp
    wl-clipboard
  ];

  # Polkit authentication agent for graphical privilege prompts.
  services.hyprpolkitagent.enable = true;
}
