import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property var list
    readonly property string cmd: list.search.text.slice(`${GlobalConfig.launcher.actionPrefix}run `.length)

    function onClicked(): void {
        if (cmd.trim().length === 0)
            return;

        Quickshell.execDetached(["sh", "-c", cmd]);
        list.screenState.launcher = false;
    }

    implicitHeight: Tokens.sizes.launcher.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Tokens.rounding.large
        onClicked: root.onClicked()
    }

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Tokens.padding.medium

        spacing: Tokens.spacing.medium

        MaterialIcon {
            text: "terminal"
            fontStyle: Tokens.font.icon.extraLarge
            Layout.alignment: Qt.AlignVCenter
        }

        StyledText {
            id: result

            color: root.cmd.length > 0 ? Colours.palette.m3onSurface : Colours.palette.m3onSurfaceVariant

            text: root.cmd.length > 0 ? qsTr("Run: %1").arg(root.cmd) : qsTr("Type a command or script to run")
            elide: Text.ElideLeft

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
