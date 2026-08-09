-- input.conf translation: input + gesture + device rules

-- Input settings
-- #############
-- ### INPUT ###
-- #############
hl.config({
    input = {
        kb_layout = "us,hr",
        kb_variant = "",
        kb_model = "",
        kb_options = "caps:swapescape",
        kb_rules = "",

        follow_mouse = 1,
        mouse_refocus = true,

        accel_profile = "flat",
        touchpad = {
            natural_scroll = true
        }
    }
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({ name = "at-translated-set-2-keyboard", kb_layout = "us,hr" })

hl.device({ name = "evision-rgb-keyboard-1", kb_layout = "us,hr" })
