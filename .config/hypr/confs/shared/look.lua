-- look.conf translation: general appearance and behavior options

-- general (col handled by colors.lua)
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 2,
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
})

-- decoration
hl.config({
    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
})

-- animations
hl.config({
    animations = {
        enabled = true,
    },
})
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-- dwindle
hl.config({
    dwindle = {
        preserve_split = true,
        force_split = 2,
    },
})

-- master
hl.config({
    master = {
        new_status = "master",
        smart_resizing = false,
    },
})

-- misc
hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
})

-- group
local C = require("confs.shared.colors")
hl.config({
    group = {
        col = {
            border_active = string.format("rgba(%06xee)", C.colors.groupBorderActive),
            border_inactive = string.format("rgba(%06xee)", C.colors.groupBorderInactive),
        },
        groupbar = {
            enabled = false,
        },
    },
})

-- cursor
hl.config({
    cursor = {
        no_warps = true,
    },
})
