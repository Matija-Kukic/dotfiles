pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

// Horizontal clock: icon · HH:MM · | · date.
StyledRect {
    id: root

    readonly property color colour: Colours.palette.m3tertiary
    readonly property int padding: Config.bar.clock.background ? Tokens.padding.medium : Tokens.padding.extraSmall
    readonly property var font: Tokens.font.body.builders.small.scale(1.1)

    implicitHeight: Tokens.sizes.bar.innerWidth
    implicitWidth: layout.implicitWidth + root.padding * 2

    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, Config.bar.clock.background ? Colours.tPalette.m3surfaceContainer.a : 0)
    radius: Tokens.rounding.full

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Tokens.spacing.small

        Loader {
            asynchronous: true
            active: Config.bar.clock.showIcon
            visible: active

            sourceComponent: MaterialIcon {
                text: "calendar_month"
                color: root.colour
            }
        }

        StyledText {
            text: `${Time.hourStr}:${Time.minuteStr}`
            font: root.font.scale(1.1).build()
            color: root.colour
            animate: true
        }

        Loader {
            asynchronous: true
            active: Config.bar.clock.showDate
            visible: active

            sourceComponent: RowLayout {
                spacing: layout.spacing

                StyledRect {
                    implicitWidth: 1
                    implicitHeight: 12
                    Layout.alignment: Qt.AlignVCenter
                    color: Colours.palette.m3outlineVariant
                }

                StyledText {
                    text: `${Time.format("ddd")} ${Time.format("d")}`
                    font: Tokens.font.body.builders.small.scale(0.9).build()
                    color: root.colour
                    animate: true
                }
            }
        }

        Loader {
            asynchronous: true
            active: GlobalConfig.services.useTwelveHourClock
            visible: active

            sourceComponent: StyledText {
                text: Time.amPmStr.toLowerCase()
                font: Tokens.font.body.builders.small.scale(0.9).build()
                color: root.colour
            }
        }
    }
}
