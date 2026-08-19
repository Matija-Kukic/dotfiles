pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils
import qs.modules.sidebar as Sidebar

// R-custom: plan quicksettings-notif-merge task-4 — notification-history tray
// popout. Reuses the sidebar's history-list component chain (NotifDockList →
// NotifGroup → NotifGroupList → Notif, all binding Notifs.list) under a
// popout-local Props instance with a distinct reloadableId ("notifhistory")
// so the persisted expanded-notif state never collides with the sidebar's.
// Width follows the notifs/sidebar/utilities convention (430); height is the
// content capped at 60% of the screen height, scrolling beyond that.
Item {
    id: root

    // R-custom: local literal matching the NotifsTokens.width convention
    // (plugin tokens.hpp NotifsTokens) — Content.qml adds 32px of its own.
    implicitWidth: 430

    readonly property int notifCount: Notifs.list.reduce((acc, n) => n.closed ? acc : acc + 1, 0)
    readonly property real maxHeight: ((QsWindow.window as QsWindow)?.screen?.height ?? 0) * 0.6
    // Maximum list height: the 60% screen cap minus the chrome (padding,
    // title row, spacing) AND minus Content.qml's extraLargeIncreased (32)
    // outer padding, so the popout's RENDERED total height (this implicitHeight
    // + 32) never exceeds 60% of the screen height. Never below one group
    // header's worth of height.
    readonly property real listMaxHeight: Math.max(TokenConfig.sizes.notifs.image + Tokens.padding.medium * 2,
        root.maxHeight - Tokens.padding.extraLargeIncreased - Tokens.padding.medium * 2 - title.implicitHeight - Tokens.spacing.medium)

    implicitHeight: Tokens.padding.medium * 2 + title.implicitHeight + Tokens.spacing.medium + clipRect.implicitHeight

    // R-custom: popout-local props. Same sidebar Props TYPE (the list
    // components require it), but its own reloadableId so PersistentProperties
    // keeps this instance's expandedNotifs in a separate state key.
    Sidebar.Props {
        id: props

        reloadableId: "notifhistory"
    }

    // R-custom: opening the history popout FLUSHES any visible transient
    // top-right popups into history (pattern: sidebar/NotifDock.qml:25 —
    // popup=false moves them from the transient model to the history list).
    Component.onCompleted: Notifs.list.forEach(n => n.popup = false)

    Item {
        id: title

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Tokens.padding.medium
        anchors.bottomMargin: 0

        implicitHeight: Math.max(count.implicitHeight, titleText.implicitHeight, clearLoader.implicitHeight)

        // R-custom: plan quicksettings-notif-merge task-7 — keep clear-all in
        // the title row so the list can never render beneath its hit target.
        Loader {
            id: clearLoader

            asynchronous: true
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            scale: root.notifCount > 0 ? 1 : 0.5
            opacity: root.notifCount > 0 ? 1 : 0
            active: opacity > 0

            sourceComponent: IconButton {
                id: clearBtn

                icon: "clear_all"
                font: Tokens.font.icon.large
                onClicked: clearTimer.start()

                Elevation {
                    anchors.fill: parent
                    radius: parent.radius
                    z: -1
                    level: clearBtn.stateLayer.containsMouse ? 4 : 3
                }
            }

            Behavior on scale {
                Anim {
                    type: Anim.FastSpatial
                }
            }

            Behavior on opacity {
                Anim {
                    type: Anim.DefaultEffects
                }
            }
        }

        StyledText {
            id: count

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: root.notifCount > 0 ? 0 : -width - titleText.anchors.leftMargin
            opacity: root.notifCount > 0 ? 1 : 0

            text: root.notifCount
            color: Colours.palette.m3outline
            font: Tokens.font.label.large

            Behavior on anchors.leftMargin {
                Anim {}
            }

            Behavior on opacity {
                Anim {
                    type: Anim.DefaultEffects
                }
            }
        }

        StyledText {
            id: titleText

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: count.right
            anchors.right: clearLoader.left
            anchors.rightMargin: Tokens.spacing.small
            anchors.leftMargin: Tokens.spacing.extraSmall

            text: root.notifCount > 0 ? qsTr("notification%1").arg(root.notifCount === 1 ? "" : "s") : qsTr("Notifications")
            color: Colours.palette.m3outline
            font: Tokens.font.label.large
            elide: Text.ElideRight
        }
    }

    ClippingRectangle {
        id: clipRect

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.margins: Tokens.padding.medium
        anchors.topMargin: Tokens.spacing.medium

        // R-custom: the list drives the popout height up to the 60% cap;
        // the empty state gets a fixed comfortable box instead (380: fits the
        // dino image + "All up to date!" caption column that the sidebar
        // shows — at 250 the caption was pushed out of the clipRect).
        implicitHeight: root.notifCount > 0
            ? Math.min(view.contentHeight, root.listMaxHeight)
            : Math.min(root.listMaxHeight, 380)

        radius: Tokens.rounding.medium
        color: "transparent"

        // Empty state — mirrors sidebar/NotifDock.qml:87-122.
        Loader {
            asynchronous: true
            anchors.centerIn: parent
            active: opacity > 0
            opacity: root.notifCount > 0 ? 0 : 1

            sourceComponent: ColumnLayout {
                id: emptyState

                spacing: Tokens.spacing.extraLarge

                Image {
                    // R-custom: plan quicksettings-notif-merge task-7 — keep
                    // the logical item box bounded; dpr is decode quality only.
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: clipRect.width * 0.8
                    Layout.preferredHeight: Math.max(0,
                        clipRect.height - emptyState.spacing - emptyCaption.implicitHeight)
                    Layout.maximumHeight: Layout.preferredHeight

                    asynchronous: true
                    source: Paths.absolutePath(Config.paths.noNotifsPic)
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: clipRect.width * 0.8 * ((QsWindow.window as QsWindow)?.devicePixelRatio ?? 1)

                    layer.enabled: true
                    layer.effect: Colouriser {
                        colorizationColor: Colours.palette.m3outlineVariant
                        brightness: 1
                    }
                }

                StyledText {
                    id: emptyCaption

                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("All up to date!")
                    color: Colours.palette.m3outlineVariant
                    font: Tokens.font.headline.builders.small.width(90).build()
                }
            }

            Behavior on opacity {
                Anim {
                    type: Anim.StandardExtraLarge
                }
            }
        }

        StyledFlickable {
            id: view

            anchors.fill: parent

            // R-custom: scrolls via the StyledScrollBar, matching the
            // sidebar's dock (Qt 6.11 removed Flickable.wheelEnabled — the
            // whole shell tree scrolls this way). The scrollbar is declared
            // AFTER the list on purpose: the sidebar declares it first, which
            // layers it UNDER the list's preventStealing MouseAreas and makes
            // clicks/drags on the scrollbar dead. Here it sits on top so the
            // popout's scroll affordance actually receives input.
            flickableDirection: Flickable.VerticalFlick
            contentWidth: width
            contentHeight: notifList.implicitHeight

            Sidebar.NotifDockList {
                id: notifList

                props: props
                screenState: ShellState.forScreen((QsWindow.window as QsWindow)?.screen) ?? null
                container: view
            }

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: view
            }
        }
    }

    // Clear-all — mirrors sidebar/NotifDock.qml:147-171 but the timer only
    // starts on click (the sidebar's auto-prune on open is NOT replicated:
    // the history popout must never silently delete history).
    Timer {
        id: clearTimer

        interval: 15
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const notifs = Notifs.notClosed;
            if (notifs.length === 0) {
                stop();
                return;
            }

            for (const n of notifs.slice(0, 30))
                n.close();
        }
    }

}
