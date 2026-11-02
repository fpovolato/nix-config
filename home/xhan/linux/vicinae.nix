{ ... }:

# Vicinae is the Raycast-like launcher on NixOS: application search,
# calculator, clipboard history, emoji picker, file search and Raycast
# extensions. Its server runs as a user service; Super+Space (bound in
# hyprland/keybinds.lua) runs `vicinae toggle`, like Command+Space for Raycast
# on the MacBook.
{
  programs.vicinae = {
    enable = true;

    systemd = {
      enable = true;
      target = "graphical-session.target";
    };

    # Settings documented by `vicinae config default`.
    settings = {
      telemetry.system_info = false;

      theme.dark.name = "catppuccin-mocha";

      font.normal.family = "JetBrainsMono Nerd Font";

      escape_key_behavior = "close_window";
      pop_to_root_on_close = true;
    };
  };
}
