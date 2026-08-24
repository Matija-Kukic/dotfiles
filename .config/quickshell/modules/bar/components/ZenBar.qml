pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property ShellScreen screen
    required property ScreenState screenState

    readonly property int activeWsId: GlobalConfig.bar.workspaces.perMonitorWorkspaces ? (Hypr.monitorFor(screen).activeWorkspace?.id ?? 1) : Hypr.activeWsId
    readonly property var occupied: {
        const occ = {};
        for (const ws of Hypr.workspaces.values)
            occ[ws.id] = ws.lastIpcObject.windows > 0;
        return occ;
    }
    readonly property int groupOffset: Math.floor((activeWsId - 1) / Config.bar.workspaces.shown) * Config.bar.workspaces.shown

    RowLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.medium

        Item {
            id: runButton

            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Tokens.padding.large

            implicitWidth: runIcon.implicitWidth + Tokens.padding.small
            implicitHeight: runIcon.implicitWidth

            StateLayer {
                anchors.fill: undefined
                anchors.centerIn: parent
                implicitWidth: runIcon.implicitWidth + Tokens.padding.small
                implicitHeight: implicitWidth
                radius: Tokens.rounding.full

                onClicked: {
                    const screenState = ShellState.forActive();
                    screenState.launcher = !screenState.launcher;
                }
            }

            MaterialIcon {
                id: runIcon

                anchors.centerIn: parent
                text: "terminal"
                color: Colours.palette.m3primary
                fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
            }
        }

        Item {
            Layout.fillWidth: true
        }

        StyledClippingRect {
            id: workspacePill

            Layout.alignment: Qt.AlignVCenter

            implicitWidth: dots.implicitWidth + Tokens.padding.small
            implicitHeight: 18

            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.full

            Row {
                id: dots

                anchors.centerIn: parent
                spacing: Tokens.spacing.small

                Repeater {
                    model: Config.bar.workspaces.shown

                    delegate: StyledRect {
                        id: dot

                        required property int index
                        readonly property int ws: root.groupOffset + index + 1

                        implicitWidth: 8
                        implicitHeight: 8
                        radius: 4
                        color: dot.ws === root.activeWsId ? Colours.palette.m3primary : root.occupied[dot.ws] ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3outlineVariant

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                const ws = dot.ws;
                                if (Hypr.activeWsId !== ws)
                                    Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ workspace = "${ws}" })` : `workspace ${ws}`);
                                else
                                    Hypr.dispatch(Hypr.usingLua ? 'hl.dsp.workspace.toggle_special("special")' : "togglespecialworkspace special");
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            id: clock

            Layout.alignment: Qt.AlignVCenter
            spacing: Tokens.spacing.small

            StyledText {
                text: `${Time.hourStr}:${Time.minuteStr}`
                font: Tokens.font.body.builders.small.build()
                color: Colours.palette.m3tertiary
                animate: true
            }

            StyledText {
                visible: Config.bar.clock.showDate
                text: "|"
                font: Tokens.font.body.builders.small.build()
                color: Colours.palette.m3tertiary
            }

            StyledText {
                visible: Config.bar.clock.showDate
                text: Time.format("ddd, dd/MM")
                font: Tokens.font.body.builders.small.build()
                color: Colours.palette.m3tertiary
                animate: true
            }
        }

        Power {
            screenState: root.screenState
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            id: exitButton

            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: Tokens.padding.large

            implicitWidth: exitIcon.implicitWidth + Tokens.padding.small
            implicitHeight: exitIcon.implicitWidth

            StateLayer {
                anchors.fill: undefined
                anchors.centerIn: parent
                implicitWidth: exitIcon.implicitWidth + Tokens.padding.small
                implicitHeight: implicitWidth
                radius: Tokens.rounding.full

                onClicked: ZenMode.enabled = false
            }

            MaterialIcon {
                id: exitIcon

                anchors.centerIn: parent
                text: "close"
                color: Colours.palette.m3onSurfaceVariant
                fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
            }
        }
    }
}
