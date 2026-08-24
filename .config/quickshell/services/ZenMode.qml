pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import Caelestia.Config
import qs.services

Singleton {
    id: root

    property alias enabled: props.enabled

    function setDynamicConfs(): void {
        Hypr.extras.applyOptions({
            "animations:enabled": 0,
            "decoration:shadow:enabled": 0,
            "decoration:blur:enabled": 0,
            "general:gaps_in": 0,
            "general:gaps_out": 0,
            "general:border_size": 1,
            "decoration:rounding": 0
        });
    }

    function setLowPower(on: bool): void {
        Quickshell.execDetached(["sudo", "-n", "/usr/sbin/tlp", on ? "bat" : "auto"]);
    }

    onEnabledChanged: {
        if (enabled) {
            setDynamicConfs();
            setLowPower(true);
            ShellState.closeZenBlockedPanels();
            if (GlobalConfig.utilities.toasts.gameModeChanged)
                Toaster.toast(qsTr("Zen mode enabled"), qsTr("Low power on, panels locked down"), "self_improvement");
        } else {
            setLowPower(false);
            Hypr.extras.message("reload");
            if (GlobalConfig.utilities.toasts.gameModeChanged)
                Toaster.toast(qsTr("Zen mode disabled"), qsTr("Power and Hyprland settings restored"), "self_improvement");
        }
    }

    PersistentProperties {
        id: props

        property bool enabled: false

        reloadableId: "zenMode"
    }

    Connections {
        function onConfigReloaded(): void {
            if (props.enabled)
                root.setDynamicConfs();
        }

        target: Hypr
    }

    IpcHandler {
        function isEnabled(): bool {
            return props.enabled;
        }

        function toggle(): void {
            props.enabled = !props.enabled;
        }

        function enable(): void {
            props.enabled = true;
        }

        function disable(): void {
            props.enabled = false;
        }

        target: "zenMode"
    }
}
