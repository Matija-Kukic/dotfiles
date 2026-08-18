import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.modules.bar as Bar
import qs.modules.dashboard as Dashboard
import qs.modules.launcher as Launcher
import qs.modules.notifications as Notifications
import qs.modules.osd as Osd
import qs.modules.session as Session
import qs.modules.sidebar as Sidebar
import qs.modules.utilities as Utilities
import qs.modules.bar.popouts as BarPopouts
import qs.modules.utilities.toasts as Toasts

Item {
    id: root

    required property ShellScreen screen
    required property ScreenState screenState
    required property Bar.BarWrapper bar
    required property real borderThickness

    readonly property alias osd: osd
    readonly property alias osdWrapper: osdWrapper
    readonly property alias notifications: notifications
    readonly property alias session: session
    readonly property alias sessionWrapper: sessionWrapper
    readonly property alias launcher: launcher
    readonly property alias dashboard: dashboard
    readonly property alias popouts: popoutsWrapper.content
    readonly property alias popoutsWrapper: popoutsWrapper
    readonly property alias utilities: utilities
    readonly property alias toasts: toasts
    readonly property alias sidebar: sidebar

    anchors.fill: parent
    anchors.margins: borderThickness
    anchors.topMargin: bar.implicitHeight

    // Clip panels to the area below the bar: opening panels (dashboard,
    // launcher, session, popouts) slide out from behind the bar instead of
    // painting over it (bar bg blob merges via the blob group behind).
    clip: true

    // R-custom: geometric mutual exclusion between below-bar surfaces
    // (sessionWrapper/launcher/dashboard as panels, popouts as hovering
    // surfaces). All compared items are panels children, so their x/width
    // are already in panels-local coords — no mapToItem dance needed.
    // One geometric rule: two surfaces may coexist only when their x-ranges
    // are disjoint (they all share the same below-bar y band).
    function xRangesOverlap(a: var, b: var): bool {
        return a.x < b.x + b.width && b.x < a.x + a.width;
    }

    // X-ranges (panels-local) of every currently OPEN panel-shape surface,
    // optionally excluding a named one. Notifications count only when
    // includeNotifs is true, and then only when height > 0 (wrapper hides via
    // visible: height > 0 — see modules/notifications/Wrapper.qml:13).
    // R-custom: plan fix-visual-defects task-4 — notifications are
    // DELIBERATELY exempt from the panel-vs-panel gate: they close/block
    // WIDGETS only, never panels (the session power menu docks BELOW them
    // instead of being refused). Popout gating (canOpenPopout + the close
    // side in Interactions.qml) passes includeNotifs=true; panel gating
    // (canOpenPanel) passes false.
    // Return type is `var` (not `array<var>`) — QtQml silently rejects unknown
    // generic annotations and coerces the function return toward void, which
    // turns every helper into `undefined` and breaks the gates.
    // Session has its `offsetScale` on the inner Session.Wrapper (id: session),
    // NOT on the outer wrapping Item (id: sessionWrapper). Launcher/Dashboard
    // are not wrapped, so they're accessed directly. Coordinates (x/width) come
    // from the wrappers for all of them — those are the panels-local geometry.
    function openPanelXRanges(name: string, includeNotifs: bool): var {
        const out = [];
        if (name !== "session" && session.offsetScale < 1 && sessionWrapper.width > 0)
            out.push({x: sessionWrapper.x, width: sessionWrapper.width});
        if (name !== "launcher" && launcher.offsetScale < 1 && launcher.width > 0)
            out.push({x: launcher.x, width: launcher.width});
        if (name !== "dashboard" && dashboard.offsetScale < 1 && dashboard.width > 0)
            out.push({x: dashboard.x, width: dashboard.width});
        if (includeNotifs && name !== "notifications" && notifications.height > 0 && notifications.width > 0)
            out.push({x: notifications.x, width: notifications.width});
        return out;
    }

    // Would-be popout x-range in PANELS-LOCAL coords given the icon's screen-x
    // center and the popout's width. Mirrors ClipWrapper.qml:25-34's clamp so
    // a right-side popout cannot extend past panels's right edge.
    // Return type is `var` (not `rect`) — `rect` is not a valid QML annotation
    // here, would be coerced to void too. Caller does `Qt.rect(r.x, 0, r.width, 1)`
    // if it needs a real rect (none currently does; the predicate uses raw x/width).
    function popoutXRange(center: real, popoutWidth: real): var {
        const off = center - borderThickness - popoutWidth / 2;
        // R-custom: clamp math mirrors ClipWrapper.qml:30: `parent.width - floor(off + width)`.
        // The leading `popoutWidth +` was a bug — it made diff always >= 0 and the
        // right-clamp dead, so x-ranges were reported wider than what ClipWrapper
        // actually renders, defeating the gate.
        const diff = root.width - Math.floor(off + popoutWidth);
        const x = diff < 0 ? off + diff : Math.max(off, 0);
        return {x: x, width: popoutWidth};
    }

    // True iff a popout centered at `center` with width `popoutWidth` would
    // have a horizontally-disjoint x-range from every currently-open panel.
    function canOpenPopout(center: real, popoutWidth: real): bool {
        const r = popoutXRange(center, popoutWidth);
        // R-custom: task-4 — popouts STILL count the visible notifications
        // panel (includeNotifs=true): notifications close/block widgets.
        for (const o of openPanelXRanges("", true))
            if (root.xRangesOverlap(r, o))
                return false;
        return true;
    }

    // True iff the named panel's x-range is disjoint from every other open panel.
    // `name` is one of: "session", "launcher", "dashboard". Unknown names → true
    // (don't block new panels the helper doesn't know about).
    function canOpenPanel(name: string): bool {
        let targetX = -1;
        let targetW = -1;
        if (name === "session") { targetX = sessionWrapper.x; targetW = sessionWrapper.width; }
        else if (name === "launcher") { targetX = launcher.x; targetW = launcher.width; }
        else if (name === "dashboard") { targetX = dashboard.x; targetW = dashboard.width; }
        else return true;
        if (targetW <= 0) return true; // not yet sized — defer to existing logic
        const r = {x: targetX, width: targetW};
        // R-custom: task-4 — panels are EXEMPT from the notifications x-range
        // (includeNotifs=false): notifications never block panels; the session
        // panel docks BELOW them instead of being refused.
        for (const o of openPanelXRanges(name, false))
            if (root.xRangesOverlap(r, o))
                return false;
        return true;
    }

    Item {
        id: osdWrapper

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        clip: sidebar.visible

        implicitWidth: osd.implicitWidth * (1 - osd.offsetScale)
        implicitHeight: osd.implicitHeight

        Osd.Wrapper {
            id: osd

            screen: root.screen
            screenState: root.screenState
            sidebarOrSessionVisible: sidebar.visible || session.visible

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
        }
    }

    Notifications.Wrapper {
        id: notifications

        screenState: root.screenState
        sidebarPanel: sidebar
        osdPanel: osdWrapper
        sessionPanel: sessionWrapper
        utilitiesPanel: utilities
        // R-custom: plan fix-visual-defects task-4 — hand the notifications
        // module a reference to the bar popouts so a notification ARRIVAL can
        // close any open popout (widgets only; panels are exempt — the session
        // panel docks BELOW this panel instead, see sessionWrapper below).
        popoutsPanel: popoutsWrapper.content

        anchors.top: parent.top
        anchors.right: parent.right
    }

    BarPopouts.ClipWrapper {
        id: popoutsWrapper

        screen: root.screen
        borderThickness: root.borderThickness
        // R-custom: geometric exclusion (plan fix-visual-defects task-3) —
        // popouts stack BELOW panels so even during mid-animation a panel
        // can paint its own bg over a popout's center (panels win).
    }

    Item {
        id: sessionWrapper

        // Topbar variant: session (power menu) drops down from the bar,
        // anchored to the top-right
        anchors.right: parent.right
        // R-custom: plan fix-visual-defects task-4 — dock BELOW the
        // notifications panel, connected (mirror of the sidebar stacking
        // below). The `-notifications.anchors.topMargin` compensation cancels
        // the notifications wrapper's -5 topMargin, so with no notifications
        // (height 0) the session top lands exactly on parent.top — pixel-
        // identical to the previous bar-docked position. No animation on the
        // reposition (sidebar precedent has none).
        anchors.top: notifications.bottom
        anchors.topMargin: -notifications.anchors.topMargin

        implicitWidth: session.implicitWidth
        implicitHeight: session.implicitHeight * (1 - session.offsetScale)

        Session.Wrapper {
            id: session

            screenState: root.screenState

            anchors.right: parent.right
            anchors.top: parent.top
        }
    }

    Launcher.Wrapper {
        id: launcher

        screen: root.screen
        screenState: root.screenState
        panels: root

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }

    Dashboard.Wrapper {
        id: dashboard

        screenState: root.screenState

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }

    Utilities.Wrapper {
        id: utilities

        screenState: root.screenState
        sidebar: sidebar
        popouts: popoutsWrapper.content

        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    Toasts.Toasts {
        id: toasts

        anchors.bottom: sidebar.visible ? parent.bottom : utilities.top
        anchors.right: sidebar.left
        anchors.margins: Tokens.padding.medium
    }

    Sidebar.Wrapper {
        id: sidebar

        screenState: root.screenState

        anchors.top: notifications.bottom
        anchors.bottom: utilities.top
        anchors.right: parent.right
        anchors.topMargin: -notifications.anchors.topMargin
    }
}
