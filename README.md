# DOTFILES

Hi, these are my current linux dotfiles.
I currently use hyprland for my wm and neovim as my ide, in neovim
some lsp servers and a python debugger are configured but more will be 
added for c/rust and others i use.
Everything is themed with everforest.
The dap.lua configuration is not present but you can configure it 
yourself in the config part of the nvim folder, guide is [here](https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python).

## Keybinds

`$mainMod` resolves to `Super`. All binds are defined in `.config/hypr/confs/shared/binds.conf`.

### Mouse

| Bind | Action |
|------|--------|
| Super + drag (left button) | Move window |
| Super + drag (right button) | Resize window |

### Launchers

| Bind | Action |
|------|--------|
| Super + Return | Launch kitty terminal |
| Super + E | Open nemo file manager |
| Super + R | Open caelestia launcher drawer |
| Super + S | Open rofi run dialog |
| Super + D | Launch zen-browser |

### System

| Bind | Action |
|------|--------|
| Super + Shift + Q | Shutdown (systemctl poweroff) |
| Super + Shift + R | Reboot (systemctl reboot) |
| Super + Shift + S | Sleep (systemctl sleep) |

### Window Management

| Bind | Action |
|------|--------|
| Super + W | Close focused window |
| Super + F | Toggle fullscreen |
| Super + T | Toggle group |
| Super + Tab | Next group member |
| Super + Shift + Tab | Previous group member |

### Focus & Window Movement

| Bind | Action |
|------|--------|
| Super + H | Focus left |
| Super + J | Focus down |
| Super + K | Focus up |
| Super + L | Focus right |
| Super + Shift + H | Move window left |
| Super + Shift + J | Move window down |
| Super + Shift + K | Move window up |
| Super + Shift + L | Move window right |
| Super + Left | Move window/group left |
| Super + Right | Move window/group right |
| Super + Down | Move window/group down |
| Super + Up | Move window/group up |

### Window Resize

| Bind | Action |
|------|--------|
| Super + Alt + H | Shrink window width |
| Super + Alt + J | Grow window height |
| Super + Alt + K | Shrink window height |
| Super + Alt + L | Grow window width |

### Workspaces

| Bind | Action |
|------|--------|
| Super + U | Switch to workspace 1 |
| Super + I | Switch to workspace 2 |
| Super + O | Switch to workspace 3 |
| Super + P | Switch to workspace 4 |
| Super + [ | Switch to workspace 5 |
| Super + Shift + U | Switch to workspace 6 |
| Super + Shift + I | Switch to workspace 7 |
| Super + Shift + O | Switch to workspace 8 |
| Super + Shift + P | Switch to workspace 9 |
| Super + Shift + [ | Switch to workspace 10 |
| Super + Shift + 1 | Move window to workspace 1 |
| Super + Shift + 2 | Move window to workspace 2 |
| Super + Shift + 3 | Move window to workspace 3 |
| Super + Shift + 4 | Move window to workspace 4 |
| Super + Shift + 5 | Move window to workspace 5 |
| Super + Shift + 6 | Move window to workspace 6 |
| Super + Shift + 7 | Move window to workspace 7 |
| Super + Shift + 8 | Move window to workspace 8 |
| Super + Shift + 9 | Move window to workspace 9 |
| Super + Shift + 0 | Move window to workspace 10 |
| Super + Alt + Right | Next workspace |
| Super + Alt + Left | Previous workspace |

### Screenshots

| Bind | Action |
|------|--------|
| Super + Print | Screenshot focused window (saved to ~/Screenshots) |
| Print | Screenshot current monitor (saved to ~/Screenshots) |
| Super + Shift + Print | Screenshot selected region (saved to ~/Screenshots) |
| Shift + Print | Screenshot selected region (copied to clipboard) |

### Keyboard Layout

| Bind | Action |
|------|--------|
| Super + Grave | Cycle keyboard layout (hyprctl switchxkblayout) |
