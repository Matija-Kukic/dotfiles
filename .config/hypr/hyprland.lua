-- Main Hyprland config (Lua)
-- Loads shared modules + active monitor profile

require("confs.shared.colors")
require("confs.shared.programs")
require("confs.shared.autostart")
require("confs.shared.env")
require("confs.shared.look")
require("confs.shared.input")
require("confs.shared.binds")
require("confs.shared.rules")
require("confs.active-monitor")  -- symlink to monitors/home.lua or monitors/hotplug.lua
