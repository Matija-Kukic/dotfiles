-- programs.conf translation: program launcher commands

local M = {}
M.terminal = "kitty"
M.fileManager = "nemo"
M.menu = "rofi -show drun"
M.runMenu = "rofi -show run"
M.browser = "zen-browser"
M.shutdown = "systemctl poweroff"
M.reboot = "systemctl reboot"
M.hibernate = "systemctl hibernate"
M.sleep = "systemctl sleep"
return M
