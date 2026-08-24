pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import Caelestia
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.widgets
import qs.services
import qs.modules.utilities as Utilities

Item {
    id: root

    required property ScreenState screenState
    required property Item osdPanel
    required property Item sessionPanel
    required property Item utilitiesPanel
    // R-custom: plan fix-visual-defects task-4 — reference to the bar popouts
    // (qs.modules.bar.popouts Wrapper). `var` (not Item): the type isn't
    // imported here and we only touch its `hasCurrent`.
    property var popoutsPanel
    readonly property int padding: Tokens.padding.large
    readonly property int clampedPadding: CUtils.clamp(padding - Config.border.thickness, 0, padding)

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    implicitWidth: Tokens.sizes.notifs.width
    // R-custom: perf — hoist the per-item height sum into its own binding so
    // clamping-only invalidations (osdPanel.y, screen height, utilities panel
    // height) don't re-run the O(n) itemAtIndex loop. rawHeight re-evaluates
    // only when list.count or a delegate's nonAnimHeight changes; implicitHeight
    // reads the cached value. Values are identical: rawHeight computes the exact
    // same sum as the inlined loop did, and the clamping logic below is unchanged.
    readonly property real rawHeight: {
        const count = list.count;
        if (count === 0)
            return 0;
        let h = (count - 1) * Tokens.spacing.medium;
        for (let i = 0; i < count; i++)
            h += (list.itemAtIndex(i) as NotifWrapper)?.nonAnimHeight ?? 0;
        return h;
    }

    implicitHeight: {
        if (list.count === 0)
            return 0;

        let height = root.rawHeight;
        const win = QsWindow.window as QsWindow;
        const border = Config.border.thickness;

        if (screenState.osd) {
            const h = osdPanel.y - clampedPadding;
            if (height > h)
                height = h;
        }

        // R-custom: plan fix-visual-defects task-4 — the session panel is now
        // docked BELOW this panel (sessionWrapper.anchors.top =
        // notifications.bottom), so sessionPanel.y depends on this height and
        // the old clamp here formed a runaway circular binding. The collision
        // it guarded against is structurally impossible after the re-anchor:
        // this panel can no longer extend past the session panel (the session
        // sits below it by construction), and the global screen-height clamp
        // below still bounds total growth.

        if (screenState.utilities) {
            const h = (win?.screen.height ?? 0) - (utilitiesPanel as Utilities.Wrapper).nonAnimHeight - border * 2 - padding * 2 - Tokens.spacing.extraLarge;
            if (height > h)
                height = h;
        }

        return Math.min((win?.screen?.height ?? 0) + padding - clampedPadding * 2 - border, height + padding + clampedPadding);
    }

    ClippingWrapperRectangle {
        anchors.fill: parent
        anchors.margins: root.padding
        anchors.topMargin: root.clampedPadding
        anchors.rightMargin: root.clampedPadding

        color: "transparent"
        radius: Tokens.rounding.large

        StyledListView {
            id: list

            model: ScriptModel {
                values: Notifs.popups.filter(n => !n.closed)
            }

            anchors.fill: parent

            orientation: Qt.Vertical
            spacing: 0
            cacheBuffer: (QsWindow.window as QsWindow)?.screen.height ?? 0

            delegate: NotifWrapper {}

            // R-custom: plan fix-visual-defects task-4 — notification ARRIVAL
            // closes any open popout (widgets only; panels are exempt — the
            // session panel docks BELOW this panel instead). Count growing =
            // arrival (dismissals/expiry shrink it); the one-time 0→N fill at
            // startup is harmless (no popout can be open yet).
            property int prevPopupCount: 0
            onCountChanged: {
                if (count > prevPopupCount && popoutsPanel?.hasCurrent)
                    popoutsPanel.hasCurrent = false;
                prevPopupCount = count;
            }

            move: Transition {
                Anim {
                    property: "y"
                }
            }

            displaced: Transition {
                Anim {
                    property: "y"
                }
            }

            ExtraIndicator {
                anchors.top: parent.top
                extra: {
                    const count = list.count;
                    if (count === 0)
                        return 0;

                    const scrollY = list.contentY;
                    const spacing = Tokens.spacing.medium;

                    let height = 0;
                    for (let i = 0; i < count; i++) {
                        height += ((list.itemAtIndex(i) as NotifWrapper)?.nonAnimHeight ?? 0) + spacing;

                        if (height - spacing >= scrollY)
                            return i;
                    }

                    return count;
                }
            }

            ExtraIndicator {
                anchors.bottom: parent.bottom
                extra: {
                    const count = list.count;
                    if (count === 0)
                        return 0;

                    const scrollY = list.contentHeight - (list.contentY + list.height);
                    const spacing = Tokens.spacing.medium;

                    let height = 0;
                    for (let i = count - 1; i >= 0; i--) {
                        height += ((list.itemAtIndex(i) as NotifWrapper)?.nonAnimHeight ?? 0) + spacing;

                        if (height - spacing >= scrollY)
                            return count - i - 1;
                    }

                    return 0;
                }
            }
        }
    }

    Behavior on implicitHeight {
        Anim {}
    }

    component NotifWrapper: Item {
        id: wrapper

        required property NotifData modelData
        required property int index
        readonly property alias nonAnimHeight: notif.nonAnimHeight
        property int idx

        onIndexChanged: {
            if (index !== -1)
                idx = index;
        }

        implicitWidth: notif.implicitWidth
        implicitHeight: notif.implicitHeight + (idx === 0 ? 0 : Tokens.spacing.medium)

        ListView.onRemove: removeAnim.start()

        SequentialAnimation {
            id: removeAnim

            PropertyAction {
                target: wrapper
                property: "ListView.delayRemove"
                value: true
            }
            PropertyAction {
                target: wrapper
                property: "enabled"
                value: false
            }
            PropertyAction {
                target: wrapper
                property: "implicitHeight"
                value: 0
            }
            PropertyAction {
                target: wrapper
                property: "z"
                value: 1
            }
            Anim {
                target: notif
                property: "x"
                to: (notif.x >= 0 ? root.implicitWidth : -root.implicitWidth) * 2
                duration: Tokens.anim.durations.normal
                easing: Tokens.anim.emphasized
            }
            PropertyAction {
                target: wrapper
                property: "ListView.delayRemove"
                value: false
            }
        }

        ClippingRectangle {
            anchors.top: parent.top
            anchors.topMargin: wrapper.idx === 0 ? 0 : Tokens.spacing.medium

            color: "transparent"
            radius: notif.radius
            implicitWidth: notif.implicitWidth
            implicitHeight: notif.implicitHeight

            Notification {
                id: notif

                modelData: wrapper.modelData
                implicitWidth: root.implicitWidth - root.padding - root.clampedPadding
            }
        }
    }

    component Anim: NumberAnimation {
        duration: Tokens.anim.durations.expressiveDefaultSpatial
        easing: Tokens.anim.expressiveDefaultSpatial
    }
}
