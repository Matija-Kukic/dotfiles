pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.services
import qs.utils

Column {
    id: root

    required property ScreenState screenState

    padding: Tokens.padding.large
    rightPadding: CUtils.clamp(padding - Config.border.thickness, 0, padding)
    spacing: Tokens.spacing.large

    // R-custom: fixed 4 actions, scheme-colored (user request)
    SessionButton {
        id: lock

        icon: "lock"
        command: ["loginctl", "lock-session"]
        colour: Colours.palette.m3primary
        onColour: Colours.palette.m3onPrimary

        KeyNavigation.down: lockSleep

        Component.onCompleted: forceActiveFocus()

        Connections {
            function onLauncherChanged(): void {
                if (!root.screenState.launcher)
                    lock.forceActiveFocus();
            }

            target: root.screenState
        }
    }

    SessionButton {
        id: lockSleep

        icon: "bedtime"
        command: ["sh", "-c", "loginctl lock-session && sleep 0.5 && systemctl suspend"]
        colour: Colours.palette.m3secondary
        onColour: Colours.palette.m3onSecondary

        KeyNavigation.up: lock
        KeyNavigation.down: restart
    }

    SessionButton {
        id: restart

        icon: "cached"
        command: ["reboot"]
        colour: Colours.palette.m3tertiary
        onColour: Colours.palette.m3onTertiary

        KeyNavigation.up: lockSleep
        KeyNavigation.down: shutdown
    }

    SessionButton {
        id: shutdown

        icon: "power_settings_new"
        command: ["poweroff"]
        colour: Colours.palette.m3error
        onColour: Colours.palette.m3onError

        KeyNavigation.up: restart
    }

    component SessionButton: IconButton {
        id: button

        required property list<string> command
        property color colour
        property color onColour

        function exec(): void {
            if (!SessionManager.exec(command))
                Quickshell.execDetached(command);
        }

        implicitWidth: Tokens.sizes.session.button
        implicitHeight: Tokens.sizes.session.button

        inactiveColour: activeFocus ? Qt.lighter(colour, 1.15) : colour
        inactiveOnColour: onColour
        radius: pressed ? Tokens.rounding.medium : activeFocus ? Tokens.rounding.extraLarge : Tokens.rounding.largeIncreased
        font: Tokens.font.icon.builders.large.scale(1.3).build()
        onClicked: exec()

        Keys.onEnterPressed: exec()
        Keys.onReturnPressed: exec()
        Keys.onEscapePressed: root.screenState.session = false
        Keys.onPressed: event => {
            if (!Config.session.vimKeybinds)
                return;

            if (event.modifiers & Qt.ControlModifier) {
                if ((event.key === Qt.Key_J || event.key === Qt.Key_N) && KeyNavigation.down) {
                    KeyNavigation.down.focus = true;
                    event.accepted = true;
                } else if ((event.key === Qt.Key_K || event.key === Qt.Key_P) && KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_Tab && KeyNavigation.down) {
                KeyNavigation.down.focus = true;
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                if (KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            }
        }
    }
}
