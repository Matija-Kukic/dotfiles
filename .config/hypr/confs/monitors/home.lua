-- home.conf translation: monitor + input sensitivity + device + workspace rules

-- ################
-- ### MONITORS ###
-- ################

hl.monitor({ output = "eDP-1", mode = "2880x1800@60.00", position = "0x0", scale = 2 })
hl.monitor({ output = "DP-1", mode = "2560x1440@120.00", position = "1440x0", scale = 1.25 })

-- Input sensitivity (home-specific override)
require("confs.shared.input") -- loads base input config
hl.config({ input = { sensitivity = 0.8 } }) -- overrides sensitivity for home setup

-- Devices
hl.device({ name = "logitech-gaming-mouse-g502", sensitivity = -0.2 })
hl.device({ name = "wacom-one-by-wacom-s-pen", output = "DP-1" })

-- Workspace rules: 1-5 -> DP-1, 6-10 -> eDP-1
for i = 1, 10 do
    local monitor = i <= 5 and "DP-1" or "eDP-1"
    hl.workspace_rule({ workspace = i, monitor = monitor })
end
