import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services

// Uptime pill: system uptime, refreshed every 60s (passive, no popouts).
StyledRect {
    id: root

    readonly property int padding: Tokens.padding.medium
    property string uptimeText: "0m"

    implicitHeight: Tokens.sizes.bar.innerWidth
    implicitWidth: layout.implicitWidth + padding * 2

    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.full

    function formatUptime(seconds: real): string {
        if (!isFinite(seconds) || seconds < 0)
            return "0m";

        const totalMinutes = Math.floor(seconds / 60);
        const days = Math.floor(totalMinutes / 1440);
        const hours = Math.floor((totalMinutes % 1440) / 60);
        const minutes = totalMinutes % 60;

        if (days > 0)
            return `${days}d ${hours}h`;
        if (hours > 0)
            return `${hours}h ${minutes}m`;
        return `${minutes}m`;
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: uptimeFile.reload()
    }

    FileView {
        id: uptimeFile

        path: "/proc/uptime"
        onLoaded: root.uptimeText = root.formatUptime(parseFloat(text().split(/\s+/)[0] ?? "0"))
    }

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Tokens.spacing.extraSmall

        MaterialIcon {
            text: "schedule"
            color: Colours.palette.m3secondary
            fontStyle: Tokens.font.icon.small
        }

        StyledText {
            text: root.uptimeText
            color: Colours.palette.m3secondary
            font: Tokens.font.body.builders.small.scale(0.9).build()
        }
    }
}
