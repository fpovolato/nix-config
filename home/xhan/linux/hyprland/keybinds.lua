-- Key bindings. See https://wiki.hypr.land/Configuring/Basics/Binds/
-- Layout mirrors AeroSpace on the MacBook, with Super in place of Option.

local mainMod = "SUPER"

local terminal = "ghostty"
local fileManager = "nautilus"
-- Vicinae, the Raycast-like launcher (home/xhan/linux/vicinae.nix).
local launcher = "vicinae toggle"

local function bind(keys, dispatcher, opts)
    hl.bind(mainMod .. " + " .. keys, dispatcher, opts)
end

-- Applications.
bind("RETURN", hl.dsp.exec_cmd(terminal))
bind("SPACE", hl.dsp.exec_cmd(launcher))
bind("E", hl.dsp.exec_cmd(fileManager))

-- Windows.
bind("Q", hl.dsp.window.close())
bind("F", hl.dsp.window.fullscreen())
bind("SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
bind("V", hl.dsp.window.float({ action = "toggle" }))
bind("P", hl.dsp.window.pseudo())
bind("SLASH", hl.dsp.layout("togglesplit"))
bind("MINUS", hl.dsp.window.resize({ x = -50, y = -50, relative = true }), { repeating = true })
bind("EQUAL", hl.dsp.window.resize({ x = 50, y = 50, relative = true }), { repeating = true })

-- Focus and move with h/j/k/l or the arrow keys.
local directions = {
    { keys = { "H", "left" }, direction = "left" },
    { keys = { "J", "down" }, direction = "down" },
    { keys = { "K", "up" }, direction = "up" },
    { keys = { "L", "right" }, direction = "right" },
}

for _, d in ipairs(directions) do
    for _, key in ipairs(d.keys) do
        bind(key, hl.dsp.focus({ direction = d.direction }))
        bind("SHIFT + " .. key, hl.dsp.window.move({ direction = d.direction }))
    end
end

-- Workspaces 1-9.
for i = 1, 9 do
    bind(tostring(i), hl.dsp.focus({ workspace = i }))
    bind("SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

bind("TAB", hl.dsp.focus({ workspace = "previous" }))
bind("SHIFT + TAB", hl.dsp.workspace.move({ monitor = "+1" }))
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad.
bind("S", hl.dsp.workspace.toggle_special("scratchpad"))
bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Move and resize with the mouse.
bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots of a selected region, copied to the clipboard.
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
bind("SHIFT + Print", hl.dsp.exec_cmd("grim - | wl-copy"))

-- Session.
bind("SHIFT + E", hl.dsp.exit())

-- Media keys, also while the screen is locked.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
