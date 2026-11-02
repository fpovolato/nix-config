-- Monitors. See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- `hyprctl monitors all` lists the connected outputs and their modes.

-- 3440x1440 ultrawide on the left, the main monitor.
hl.monitor({ output = "DP-3", mode = "highrr", position = "0x0", scale = 1 })

-- 2560x1440 on the right.
hl.monitor({ output = "DP-2", mode = "highrr", position = "3440x0", scale = 1 })

-- Any other output that gets connected.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
