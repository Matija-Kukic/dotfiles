-- #################
-- ### AUTOSTART ###
-- #################

-- nm-applet retired 2026-08-04: caelestia bar network icon + popout (Nmcli) replaces it
--hl.exec_cmd("nm-applet &")
--hl.exec_cmd("waybar")
-- hyprpaper retired 2026-08-06 (R3): caelestia Background renders the wallpaper
-- (source: ~/.local/state/caelestia/wallpaper/path.txt, written by switch-theme)

hl.on("hyprland.start", function()
    hl.exec_cmd("env CAELESTIA_WALLPAPERS_DIR=$HOME/dotfiles/wallpapers qs")
    hl.exec_cmd("odmori_oci")

    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_THEME")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_THEME")
end)
