-- hotplug.conf translation: monitor + input sensitivity + device + workspace rules

-- ################
-- ### MONITORS ###
-- ################

hl.monitor({ output = "eDP-1", mode = "2880x1800@60.00", position = "0x0", scale = 2 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })

-- Input sensitivity (hotplug-specific override)
require("confs.shared.input") -- loads base input config
hl.config({ input = { sensitivity = 0.6 } }) -- overrides sensitivity for hotplug setup

-- Devices
hl.device({ name = "wacom-one-by-wacom-s-pen", output = "eDP-1" })

-- Workspace rules: 1-5 -> eDP-1
for i = 1, 5 do
    hl.workspace_rule({ workspace = i, monitor = "eDP-1" })
end
