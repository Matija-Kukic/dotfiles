import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.common

// MINI bar — thin omarchy/macOS-style strip (phase 1 skeleton):
// centered workspace dots + clock. Status icons land in phase 2.
PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 26
    color: Theme.bg

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Item { Layout.fillWidth: true }

        // ── Workspace dots ──
        Repeater {
            model: [...Hyprland.workspaces.values].sort((a, b) => a.id - b.id)

            delegate: Rectangle {
                required property var modelData
                readonly property bool active: modelData.active

                Layout.preferredWidth: active ? 18 : 8
                Layout.preferredHeight: 8
                radius: 4
                color: active ? Theme.accent : Theme.muted

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + modelData.id)
                }
            }
        }

        // ── Clock ──
        Text {
            id: clock
            color: Theme.fg
            font.family: Theme.fontUi
            font.pixelSize: 12

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
            }
        }

        Item { Layout.fillWidth: true }
    }
}
