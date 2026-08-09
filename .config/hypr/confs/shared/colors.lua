-- colors.conf translation: read semantic colors from the active colorscheme

local home = os.getenv("HOME")
local scheme = home .. "/.config/colorschemes/active/hyprland.lua"
local ok, colors = pcall(dofile, scheme)
if not ok or not colors then
    colors = {
        borderActive = 0xb4befe, borderActiveAlt = 0xf2cdcd,
        borderInactive = 0x1e1e2e, groupBorderActive = 0x74c7ec,
        groupBorderInactive = 0x181825,
    }
end

hl.config({
    general = {
        col = {
            active_border = {
                colors = {
                    string.format("rgba(%06xee)", colors.borderActive),
                    string.format("rgba(%06xee)", colors.borderActiveAlt),
                },
                angle = 45,
            },
            inactive_border = string.format("rgba(%06xee)", colors.borderInactive),
        },
    },
})

local M = { colors = colors }
return M
