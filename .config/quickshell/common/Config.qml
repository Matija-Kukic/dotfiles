pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// User preferences / runtime state. Persisted OUTSIDE the repo in
// ~/.local/state/quickshell/ (written by helper scripts like qs-bar-toggle),
// watched here so changes apply live without a shell restart.
QtObject {
    id: config

    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/quickshell"

    // "full" | "mini"
    property string barVariant: "full"
    // mini bar autohide (later phases)
    property bool miniAutohide: false

    property FileView variantFile: FileView {
        path: config.stateDir + "/bar-variant"
        Component.onCompleted: config.apply(text())
        onTextChanged: config.apply(text())
    }

    // watchChanges is unreliable in this qs build — poll instead.
    property Timer pollTimer: Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: variantFile.reload()
    }

    function apply(text) {
        const v = (text ?? "").trim();
        if (v === "full" || v === "mini")
            config.barVariant = v;
    }
}
