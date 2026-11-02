-- Environment variables for Hyprland and the programs it starts.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Cursor installed by home/xhan/linux/theme.nix.
hl.env("XCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Run Electron and Chromium apps (Obsidian, Spotify, Chromium) natively on
-- Wayland.
hl.env("NIXOS_OZONE_WL", "1")
