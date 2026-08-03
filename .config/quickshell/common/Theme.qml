pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Central palette, driven by ~/.config/colorschemes/<active>/quickshell.json.
//
// A symlink repoint of colorschemes/active is invisible to inotify, so
// instead we watch the scheme NAME file that switch-theme maintains; the
// palette FileView's path is a binding on that name — when it changes, the
// file is genuinely different and loads fresh.
QtObject {
    id: theme

    readonly property string statePath: Quickshell.env("HOME") + "/.local/state/colorscheme/active"

    property string schemeName: "catppuccin-mocha"
    property var data: ({})

    readonly property string bg: data.bg ?? "#1e1e2e"
    readonly property string surface: data.surface ?? "#313244"
    readonly property string surfaceHigh: data.surfaceHigh ?? "#45475a"
    readonly property string fg: data.fg ?? "#cdd6f4"
    readonly property string muted: data.muted ?? "#6c7086"
    readonly property string accent: data.accent ?? "#cba6f7"
    readonly property string accentAlt: data.accentAlt ?? "#89b4fa"
    readonly property string error: data.error ?? "#f38ba8"
    readonly property string warn: data.warn ?? "#f9e2af"

    // M3-ish type scale (Noto Sans for UI, FiraCode for mono/glyphs)
    readonly property string fontUi: "Noto Sans"
    readonly property string fontMono: "FiraCode Nerd Font"
    readonly property int fontSize: 13
    readonly property int radius: 12

    property FileView nameFile: FileView {
        id: nameFile
        path: theme.statePath
        Component.onCompleted: theme.applyName(text())
        onTextChanged: theme.applyName(text())
    }

    // watchChanges is unreliable in this qs build — poll instead.
    property Timer pollTimer: Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: nameFile.reload()
    }

    property FileView schemeFile: FileView {
        id: schemeFile
        path: Quickshell.env("HOME") + "/.config/colorschemes/" + theme.schemeName + "/quickshell.json"
        watchChanges: true
        Component.onCompleted: theme.parse(text())
        onTextChanged: theme.parse(text())
    }

    function applyName(text) {
        const name = (text ?? "").trim();
        if (name !== "" && name !== theme.schemeName)
            theme.schemeName = name;
    }

    function parse(text) {
        if (!text || !text.trim())
            return;
        try {
            data = JSON.parse(text);
        } catch (e) {
            console.warn("Theme: failed to parse palette for", schemeName, e);
        }
    }
}
