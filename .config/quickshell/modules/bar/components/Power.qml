pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property ScreenState screenState

    implicitWidth: icon.implicitWidth + Tokens.padding.small
    implicitHeight: icon.implicitWidth

    // R-custom: geometric exclusion (plan fix-visual-defects task-3) —
    // back-reference to the active Panels, used by the onClicked gate below
    // to refuse opening session over a centered panel (launcher/dashboard).
    // Null-safe: this Power component is also used by the nexus shell which
    // may not have a Panels instance on the active screen.
    readonly property var panels: ShellState.componentsForActive()?.panels ?? null

    StateLayer {
        // Cursed workaround to make the area larger than the parent
        anchors.fill: undefined
        anchors.centerIn: parent
        implicitWidth: icon.implicitWidth + Tokens.padding.small
        implicitHeight: implicitWidth
        radius: Tokens.rounding.full
        onClicked: {
            // R-custom: geometric exclusion — if the session's would-be
            // x-range overlaps an open panel, refuse to flip the state
            // (closing is always allowed; only opening is gated).
            if (root.screenState.session || !root.panels || root.panels.canOpenPanel("session"))
                root.screenState.session = !root.screenState.session;
        }
    }

    MaterialIcon {
        id: icon

        anchors.centerIn: parent

        text: "power_settings_new"
        color: Colours.palette.m3error
        fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
    }
}
