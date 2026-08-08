pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services

Column {
    id: root

    readonly property var monitor: Brightness.monitors.find(m => !m.isDdc) ?? Brightness.monitors[0] ?? null

    spacing: Tokens.spacing.medium

    StyledText {
        text: root.monitor ? qsTr("Brightness: %1%").arg(Math.round(root.monitor.brightness * 100)) : qsTr("No brightness control detected")
    }

    StyledText {
        text: qsTr("Scroll on the bar to adjust")
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.label.small
    }
}
