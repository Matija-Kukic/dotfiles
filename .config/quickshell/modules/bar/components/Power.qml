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

    StateLayer {
        // Cursed workaround to make the area larger than the parent
        anchors.fill: undefined
        anchors.centerIn: parent
        implicitWidth: icon.implicitWidth + Tokens.padding.small
        implicitHeight: implicitWidth
        radius: Tokens.rounding.full
        onClicked: root.screenState.session = !root.screenState.session
    }

    MaterialIcon {
        id: icon

        anchors.centerIn: parent

        text: "power_settings_new"
        color: Colours.palette.m3error
        fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
    }
}
