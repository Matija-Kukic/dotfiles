pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services
import qs.utils
import qs.modules.bar.components.status

// Horizontal status-icons pill: entries laid out left→right.
StyledRect {
    id: root

    required property ShellScreen screen
    property color colour: Colours.palette.m3secondary
    readonly property alias items: iconRow

    readonly property int spacing: Tokens.spacing.medium / 2

    // Index of the first/last entry that isn't collapsed, for edge margin gating
    readonly property int firstPresent: {
        const values = model.values;
        for (let i = 0; i < values.length; i++)
            if (!collapsed(values[i]))
                return i;
        return -1;
    }
    readonly property int lastPresent: {
        const values = model.values;
        for (let i = values.length - 1; i >= 0; i--)
            if (!collapsed(values[i]))
                return i;
        return -1;
    }

    // Entries that can shrink to nothing, spacing included
    function collapsed(entry: var): bool {
        if (entry.id === "lockStatus")
            return !Hypr.capsLock && !Hypr.numLock;
        return false;
    }

    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.full

    // R-custom: plan quicksettings-notif-merge task-4 — the virtual
    // notification-history entry object injected into the icons model above.
    QtObject {
        id: bellEntry

        property string id: "NotifHistory"
        property bool enabled: true
    }

    clip: true
    implicitHeight: Tokens.sizes.bar.innerWidth
    implicitWidth: iconRow.implicitWidth + Tokens.padding.medium * 2

    RowLayout {
        id: iconRow

        anchors.left: parent.left
        anchors.leftMargin: Tokens.padding.medium
        anchors.verticalCenter: parent.verticalCenter

        spacing: 0

        Repeater {
            model: ScriptModel {
                id: model

                // R-custom: plan quicksettings-notif-merge task-4 — inject the
                // notification-history bell as a virtual entry immediately
                // right of brightness (appended at the end if brightness is
                // absent/disabled). QML-side only: no config schema changes,
                // and both monitors' bars get it through this same model.
                // The entry is a QObject (bellEntry below) so it survives the
                // ScriptModel update-diff as a stable identity.
                values: {
                    const values = root.Config.bar.statusIcons.values.filter(e => e.enabled);
                    const idx = values.findIndex(e => e.id === "brightness");
                    if (idx >= 0)
                        values.splice(idx + 1, 0, bellEntry);
                    else
                        values.push(bellEntry);
                    return values;
                }
            }

            DelegateChooser {
                role: "id"

                DelegateChoice {
                    roleValue: "lockStatus"
                    delegate: EntryWrapper {
                        LockStatus {
                            colour: root.colour
                            parentSpacing: root.spacing
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "audio"
                    delegate: EntryWrapper {
                        margin: Tokens.spacing.extraSmall / 2

                        MaterialIcon {
                            animate: true
                            text: Icons.getVolumeIcon(Audio.volume, Audio.muted)
                            color: root.colour
                            fontStyle: Tokens.font.icon.medium
                            fill: 1
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "microphone"
                    delegate: EntryWrapper {
                        margin: Tokens.spacing.extraSmall / 2
                        name: "audio" // Mic opens audio popout

                        MaterialIcon {
                            animate: true
                            text: Icons.getMicVolumeIcon(Audio.sourceVolume, Audio.sourceMuted)
                            color: root.colour
                            fontStyle: Tokens.font.icon.medium
                            fill: 1
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "kbLayout"
                    delegate: EntryWrapper {
                        StyledText {
                            animate: true
                            text: Hypr.kbLayout
                            color: root.colour
                            font: Tokens.font.mono.medium
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "network"
                    delegate: EntryWrapper {
                        MaterialIcon {
                            animate: true
                            text: Nmcli.activeEthernet ? "cable" : Nmcli.active ? Icons.getNetworkIcon(Nmcli.active.strength ?? 0) : "wifi_off"
                            color: root.colour
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "bluetooth"
                    delegate: EntryWrapper {
                        BluetoothStatus {
                            colour: root.colour
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "battery"
                    delegate: EntryWrapper {
                        BatteryStatus {
                            colour: root.colour
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "brightness"
                    delegate: EntryWrapper {
                        margin: Tokens.spacing.extraSmall / 2

                        MaterialIcon {
                            animate: true
                            text: `brightness_${Math.round((Brightness.getMonitorForScreen(root.screen)?.brightness ?? 0) * 6) + 1}`
                            color: root.colour
                            fontStyle: Tokens.font.icon.medium
                            fill: 1
                        }
                    }
                }
                // R-custom: plan quicksettings-notif-merge task-4 — bell entry
                // for the notification-history popout. Mirrors the brightness
                // delegate (margin/animate/color/fontStyle/fill). Click is
                // deliberately INERT: hover-only, no onClicked anywhere.
                // roleValue MUST match the injected entry's `id` exactly —
                // DelegateChooser matching is case-sensitive.
                DelegateChoice {
                    roleValue: "NotifHistory"
                    delegate: EntryWrapper {
                        margin: Tokens.spacing.extraSmall / 2

                        MaterialIcon {
                            animate: true
                            text: "notifications"
                            color: root.colour
                            fontStyle: Tokens.font.icon.medium
                            fill: 1
                        }
                    }
                }
            }
        }
    }

    component EntryWrapper: Item {
        required property var modelData
        required property int index
        property int margin: root.spacing / 2
        readonly property bool present: !root.collapsed(modelData)
        property real leftGap: present && index !== root.firstPresent ? margin : 0
        property real rightGap: present && index !== root.lastPresent ? margin : 0
        default property Item item
        property string name: modelData.id.toLowerCase()

        Layout.leftMargin: Math.round(leftGap)
        Layout.rightMargin: Math.round(rightGap)
        Layout.alignment: Qt.AlignVCenter

        implicitWidth: present ? (item?.implicitWidth ?? 0) : 0
        implicitHeight: present ? (item?.implicitHeight ?? 0) : 0

        Behavior on implicitWidth {
            Anim {
                type: Anim.SlowEffects
            }
        }

        children: item

        Behavior on leftGap {
            Anim {
                type: Anim.SlowEffects
            }
        }

        Behavior on rightGap {
            Anim {
                type: Anim.SlowEffects
            }
        }
    }
}
