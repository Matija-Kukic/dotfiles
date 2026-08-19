import QtQuick
import QtQuick.Templates
import Caelestia.Config
import qs.components
import qs.services

RadioButton {
    id: root

    // R-custom: opt-in width cap; Infinity preserves existing consumers.
    property real maxContentWidth: Infinity

    font: Tokens.font.body.small

    // R-custom: cap only when requested so the default stays content-driven.
    implicitWidth: Math.min(maxContentWidth, implicitIndicatorWidth + implicitContentWidth + contentItem.anchors.leftMargin)
    implicitHeight: Math.max(implicitIndicatorHeight, implicitContentHeight)

    indicator: Rectangle {
        id: outerCircle

        implicitWidth: 20
        implicitHeight: 20
        radius: Tokens.rounding.full
        color: "transparent"
        border.color: root.checked ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
        border.width: 2
        anchors.verticalCenter: parent.verticalCenter

        StateLayer {
            anchors.margins: -Tokens.padding.small
            color: root.checked ? Colours.palette.m3onSurface : Colours.palette.m3primary
            z: -1
            onClicked: root.click()
        }

        StyledRect {
            anchors.centerIn: parent
            implicitWidth: 8
            implicitHeight: 8

            radius: Tokens.rounding.full
            color: Qt.alpha(Colours.palette.m3primary, root.checked ? 1 : 0)
        }

        Behavior on border.color {
            CAnim {}
        }
    }

    contentItem: StyledText {
        text: root.text
        font: root.font
        // R-custom: bind text to the capped button width so right elision engages.
        elide: Text.ElideRight
        maximumLineCount: 1
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: outerCircle.right
        anchors.leftMargin: Tokens.spacing.medium
        anchors.right: parent.right
    }
}
