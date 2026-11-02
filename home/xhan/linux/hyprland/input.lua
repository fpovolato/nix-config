-- Keyboard and mouse. See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
    input = {
        kb_layout = "us",
        -- Caps Lock acts as Control, like on the MacBook.
        kb_options = "ctrl:nocaps",

        repeat_delay = 300,
        repeat_rate = 40,

        -- Keyboard focus follows the mouse pointer.
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
    },
})
