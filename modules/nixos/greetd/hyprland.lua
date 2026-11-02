-- Hyprland configuration of the login screen, run as the greeter user.
-- It shows ReGreet on the LG main monitor and exits when ReGreet does.

-- Only the LG UltraGear (DP-2) is enabled, so ReGreet fullscreens there.
hl.monitor({ output = "DP-2", mode = "highrr", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-3", disabled = true })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.env("XCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("XCURSOR_SIZE", "24")

hl.config({
    input = {
        kb_layout = "us",
        kb_options = "ctrl:nocaps",
    },

    animations = {
        enabled = false,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        disable_hyprland_guiutils_check = true,
        disable_watchdog_warning = true,
    },

    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("@regreet@; @hyprctl@ dispatch 'hl.dsp.exit()'")
end)
