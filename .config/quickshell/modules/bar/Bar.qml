import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.common

// FULL bar — end-4 classic arrangement (phase 1 skeleton):
// left: workspaces · center: clock · right: (status cluster in phase 2)
PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 36
    color: Theme.bg

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 6

        // ── Workspaces ──
        Repeater {
            model: [...Hyprland.workspaces.values].sort((a, b) => a.id - b.id)

            delegate: Rectangle {
                required property var modelData
                readonly property bool active: modelData.active

                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: Theme.radius
                color: active ? Theme.accent : (hover.hovered ? Theme.surfaceHigh : Theme.surface)

                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    color: active ? Theme.bg : Theme.fg
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSize
                    font.bold: active
                }

                HoverHandler {
                    id: hover
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + modelData.id)
                }
            }
        }

        Item { Layout.fillWidth: true }

        // ── Clock ──
        Text {
            id: clock
            color: Theme.fg
            font.family: Theme.fontUi
            font.pixelSize: Theme.fontSize
            font.bold: true

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
            }
        }

        Item { Layout.fillWidth: true }

        // ── Right stub (cluster lands here in phase 2) ──
        Text {
            text: "full"
            color: Theme.muted
            font.family: Theme.fontUi
            font.pixelSize: Theme.fontSize
        }
    }
}
