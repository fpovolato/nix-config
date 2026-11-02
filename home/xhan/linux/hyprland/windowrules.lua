-- Window and layer rules. See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- `hyprctl clients` shows the class and title of open windows.

-- Ignore maximize requests from applications.
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix dragging issues with XWayland, from Hyprland's example configuration.
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- Spotify on workspace 8, as on the MacBook.
hl.window_rule({
    name = "spotify-workspace",
    match = { class = "^(spotify|Spotify)$" },
    workspace = "8",
})

-- Small utility windows float in the middle of the screen.
hl.window_rule({
    name = "float-utilities",
    match = { class = "^(com\\.saivert\\.pwvucontrol|nm-connection-editor)$" },
    float = true,
    size = "900 600",
    center = true,
})

-- File pickers and other portal dialogs.
hl.window_rule({
    name = "float-file-dialogs",
    match = { title = "^(Open File|Save File|Open Folder|Select a File|Save As)(.*)$" },
    float = true,
    center = true,
})

-- Browser picture-in-picture stays on top of every workspace.
hl.window_rule({
    name = "pip",
    match = { title = "^Picture.in.[Pp]icture$" },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
})

-- Blur behind the Quickshell bar (namespace set in quickshell/Bar.qml).
hl.layer_rule({
    name = "blur-quickshell-bar",
    match = { namespace = "^quickshell-bar$" },
    blur = true,
    ignore_alpha = 0.3,
})
