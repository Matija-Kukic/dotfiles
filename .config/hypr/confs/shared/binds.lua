-- binds.conf translation: keybindings

local P = require("confs.shared.programs")
local mainMod = "SUPER"

-- Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Launchers
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(P.terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(P.fileManager))
-- R4: caelestia launcher (was: exec, $menu = rofi drun)
hl.bind(mainMod .. " + R", hl.dsp.global("caelestia:launcher"))
-- rofi run kept: caelestia launcher has no shell-run mode
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(P.runMenu))
hl.bind(mainMod .. " + T", hl.dsp.group.toggle())
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(P.browser))

-- System
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(P.shutdown))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(P.reboot))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(P.sleep))

-- R5: qs-bar-toggle retired -- legacy script toggled the hand-made shell's
-- full/mini bar variant; caelestia has no variant concept and its
-- `drawers toggle bar` is inert with bar.persistent=true.

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- Focus (H=left, L=right, K=up, J=down)
local focus_dirs = { { key = "H", dir = "l" }, { key = "L", dir = "r" }, { key = "K", dir = "u" }, { key = "J", dir = "d" } }
for _, f in ipairs(focus_dirs) do
    hl.bind(mainMod .. " + " .. f.key, hl.dsp.focus({ direction = f.dir }))
end

-- Workspace focus 1-10 (U/I/O/P/bracketleft and SHIFT variants)
local ws_keys = { "U", "I", "O", "P", "bracketleft", "SHIFT + U", "SHIFT + I", "SHIFT + O", "SHIFT + P", "SHIFT + bracketleft" }
for i = 1, 10 do
    hl.bind(mainMod .. " + " .. ws_keys[i], hl.dsp.focus({ workspace = i }))
end

-- Move window to workspace 1-10 (SHIFT + 1..9, SHIFT + 0)
for i = 1, 10 do
    local key = i == 10 and "0" or tostring(i)
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Relative workspace switch (ALT/alt both become "ALT")
hl.bind(mainMod .. " + ALT + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + ALT + left", hl.dsp.focus({ workspace = "e-1" }))

-- Resize active window (L=+x, H=-x, K=-y, J=+y)
local resize_dirs = { { key = "L", x = 10, y = 0 }, { key = "H", x = -10, y = 0 }, { key = "K", x = 0, y = -10 }, { key = "J", x = 0, y = 10 } }
for _, r in ipairs(resize_dirs) do
    hl.bind(mainMod .. " + ALT + " .. r.key, hl.dsp.window.resize({ x = r.x, y = r.y, relative = true }))
end

-- Move window (SHIFT + H/L/K/J)
local move_keys = { { key = "H", dir = "l" }, { key = "L", dir = "r" }, { key = "K", dir = "u" }, { key = "J", dir = "d" } }
for _, m in ipairs(move_keys) do
    hl.bind(mainMod .. " + SHIFT + " .. m.key, hl.dsp.window.move({ direction = m.dir }))
end

-- Move window or group (arrow keys)
local group_keys = { { key = "left", dir = "l" }, { key = "right", dir = "r" }, { key = "down", dir = "d" }, { key = "up", dir = "u" } }
for _, g in ipairs(group_keys) do
    hl.bind(mainMod .. " + " .. g.key, hl.dsp.window.move({ direction = g.dir, group_aware = true }))
end

-- Group cycling
hl.bind(mainMod .. " + TAB", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.group.prev())

-- Keyboard layout cycling
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd([[switch=$(hyprctl devices -j | jq -r '.keyboards[] | .active_keymap' | uniq -c | [ $(wc -l) -eq 1 ] && echo "next" || echo "0"); for device in $(hyprctl devices -j | jq -r '.keyboards[] | .name'); do hyprctl switchxkblayout $device $switch; done]]))

-- Screenshots
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m window -o Screenshots"))
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m output -o Screenshots"))
hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m region -o Screenshots"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
