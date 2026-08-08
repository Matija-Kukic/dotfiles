pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Caelestia.Blobs
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import qs.modules.bar

StyledWindow {
    id: root

    readonly property alias bar: bar
    readonly property alias interactionWrapper: interactions

    readonly property ScreenState screenState: ShellState.forScreen(screen)

    readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
    readonly property bool hasSpecialWorkspace: (monitor?.lastIpcObject.specialWorkspace?.name.length ?? 0) > 0
    readonly property bool hasFullscreenOnNormalWs: monitor?.activeWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen > 1) ?? false
    readonly property bool hasFullscreen: {
        if (hasSpecialWorkspace) {
            const specialName = monitor?.lastIpcObject.specialWorkspace?.name;
            if (!specialName)
                return false;
            const specialWs = Hypr.workspaces.values.find(ws => ws.name === specialName);
            return specialWs?.toplevels.values.some(t => t.lastIpcObject.fullscreen > 1) ?? false;
        }
        return hasFullscreenOnNormalWs;
    }

    property real fsTransitionProg: hasFullscreen ? 1 : 0
    readonly property real sdfBorderOffset: 2 * fsTransitionProg // SDFs joins are not exact, so offset by 2px to ensure nothing shows
    readonly property real borderThickness: contentItem.Config.border.thickness * (1 - fsTransitionProg)
    readonly property real borderRounding: contentItem.Config.border.rounding * (1 - fsTransitionProg)
    readonly property real shadowOpacity: 0.7 * (1 - fsTransitionProg)
    readonly property real borderLayoutThickness: hasFullscreen ? 0 : contentItem.Config.border.thickness

    property color surfaceColour: Colours.tPalette.m3surface

    readonly property int dragMaskPadding: {
        if (focusGrab.active || panels.popouts.isDetached)
            return 0;

        if (monitor?.lastIpcObject.specialWorkspace?.name || monitor?.activeWorkspace?.lastIpcObject.windows > 0)
            return 0;

        const thresholds = [];
        for (const panel of ["dashboard", "launcher", "session", "sidebar"])
            if (contentItem.Config[panel].enabled)
                thresholds.push(contentItem.Config[panel].dragThreshold);
        return Math.max(...thresholds);
    }

    onHasFullscreenChanged: {
        screenState.launcher = false;
        screenState.session = false;
        screenState.dashboard = false;
        panels.popouts.close();
    }

    name: "drawers"
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: (fsTransitionProg > 0 && contentItem.Config.general.showOverFullscreen) || (hasSpecialWorkspace && hasFullscreenOnNormalWs) ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.keyboardFocus: screenState.launcher || screenState.session ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    mask: hasFullscreen ? emptyRegion : regions

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    Behavior on fsTransitionProg {
        Anim {}
    }

    Behavior on surfaceColour {
        CAnim {}
    }

    Region {
        id: emptyRegion

        x: panels.notifications.x + root.borderThickness
        y: panels.notifications.y + bar.implicitHeight
        width: panels.notifications.width
        height: panels.notifications.height

        Region {
            x: root.width - width
            y: panels.osdWrapper.y + bar.implicitHeight
            width: panels.osdWrapper.width * (1 - panels.osd.offsetScale) + root.borderThickness
            height: panels.osd.height
        }
    }

    Regions {
        id: regions

        bar: bar
        panels: panels
        win: root
    }

    HyprlandFocusGrab {
        id: focusGrab

        active: {
            const s = root.screenState;
            const conf = root.contentItem.Config;
            if ((s.launcher && conf.launcher.enabled) || (s.session && conf.session.enabled) || (s.sidebar && conf.sidebar.enabled))
                return true;
            if (!conf.dashboard.showOnHover && s.dashboard && conf.dashboard.enabled)
                return true;
            if (panels.popouts.currentName.startsWith("traymenu") && (panels.popouts.current as StackView)?.depth > 1)
                return true;
            return false;
        }
        windows: [root]
        onCleared: {
            root.screenState.launcher = false;
            root.screenState.session = false;
            root.screenState.sidebar = false;
            root.screenState.dashboard = false;
            panels.popouts.hasCurrent = false;
            bar.closeTray();
        }
    }

    StyledRect {
        anchors.fill: parent
        opacity: (root.screenState.session && Config.session.enabled) || panels.popouts.detachedMode !== "" ? 0.5 : 0
        color: Colours.palette.m3scrim

        Behavior on opacity {
            Anim {
                type: Anim.SlowEffects
            }
        }
    }

    Item {
        anchors.fill: parent
        opacity: root.surfaceColour.a
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            blurMax: 15
            shadowColor: Qt.alpha(Colours.palette.m3shadow, Math.max(0, root.shadowOpacity))
        }

        BlobGroup {
            id: blobGroup

            color: root.surfaceColour
            smoothing: root.contentItem.Config.border.smoothing
            // R-custom: cornerFill squares panel corners near the frame's inner
            // edge (blobshape.cpp:316-346) — at border.thickness 0 the invisible
            // frame bands sit flush at the screen edges, so the squaring painted
            // the concave notch at the sidebar's bottom-right corner. Disabled
            // group-wide; in-tree precedent modules/dashboard/media/LyricsInfo.qml:23
            // and modules/nexus/common/BlobPopup.qml:35. Rung 2: the T4 push
            // (invisibleEdgePush below) is KEPT — harmless, and it helps the
            // bridge distance.
            cornerFill: false
        }

        BlobInvertedRect {
            anchors.fill: parent
            anchors.margins: -50 // Make border thicker to smooth out bulge from closed drawers
            group: blobGroup
            radius: root.borderRounding
            // R-custom: with a zero-thickness border the left/right/bottom frame bands
            // lie entirely off-screen, but panels flush with the screen edge still
            // smooth-merged with them: cornerFill squared their near corners and the
            // smin bridge dipped below the bottom edge, painting a concave notch with
            // a dangling tail at bottom-right corners (audio/brightness popouts,
            // session, notifications). Push those invisible inner edges past the blend
            // zone so edge-flush panels keep clean rounded corners. Push = smoothing + 2
            // keeps the kFrame clamp intact for smoothing <= 23 (default 20).
            // Rung 1: push widened because the SDF blend/near-border margin reaches pad*2 (blobshape.cpp:271-281), beyond smoothing + 2; kFrame shrinks to 50 - 42 - 1 = 7 (blob.frag:250), invisible because all frame bands are off-screen at border.thickness 0 and border.rounding is 0.
            readonly property real invisibleEdgePush: root.contentItem.Config.border.thickness > 0 ? 0 : Math.min(2 * root.contentItem.Config.border.smoothing + 2, 45)
            borderLeft: root.borderThickness - anchors.margins - root.sdfBorderOffset - invisibleEdgePush
            borderRight: root.borderThickness - anchors.margins - root.sdfBorderOffset - invisibleEdgePush
            borderTop: bar.implicitHeight - anchors.margins - root.sdfBorderOffset
            borderBottom: root.borderThickness - anchors.margins - root.sdfBorderOffset - invisibleEdgePush
        }

        PanelBg {
            id: dashBg

            panel: panels.dashboard
            deformAmount: 0.1
        }

        PanelBg {
            id: launcherBg

            panel: panels.launcher
            deformAmount: 0.1
        }

        PanelBg {
            id: sessionBg

            panel: panels.sessionWrapper
            deformAmount: 0.2
            // R-custom: user request 2026-08-08 — flat connection where the
            // panel meets the screen edge / bar-at-edge junction; proven lever
            // from the 2026-08-08 notch fix rung 3; cornerFill:false +
            // invisibleEdgePush 42 + hidden-sidebar excludes left untouched on
            // purpose. TL keeps the praised bar-merge rounding and BL stays
            // rounded/floating — both deliberately NOT flattened.
            topRightRadius: 0
            bottomRightRadius: 0
        }

        PanelBg {
            id: sidebarBg

            panel: panels.sidebar
            deformAmount: 0.03
            implicitHeight: panel.height * (1 / rawDeformMatrix.m22) + 2
            // R-custom: when hidden (offsetScale → 1, off-screen right), don't
            // metaball-merge with top-right panels — the bridge drew a phantom
            // rounded tail below their bottom-right corners (user report
            // 2026-08-07). utilsBg stays excluded when open (original behavior).
            exclude: panels.sidebar.offsetScale > 0.08 ? [notifsBg, sessionBg, popoutBg] : [utilsBg]
            bottomLeftRadius: Math.max(0, Math.min(1, panels.sidebar.offsetScale / 0.3)) * radius
            // R-custom: user-authorized flat corner ("just make it flat or
            // remove it" — SESSION_HANDOFF.md:27-28); kills the notch
            // deterministically — no arc left for the smin bridge to crease.
            // The artifact at this screen-flush br corner survived push 42 (T4)
            // and cornerFill:false (T5), both proven geometrically incapable
            // (near-border test needs push > 60, kFrame caps at 45; cornerFill
            // factor already clamped to 1 at this corner).
            bottomRightRadius: 0
            // R-custom: user request 2026-08-08 — flat connection where the
            // panel meets the screen edge / bar-at-edge junction; proven lever
            // from the 2026-08-08 notch fix rung 3; cornerFill:false +
            // invisibleEdgePush 42 + hidden-sidebar excludes left untouched on
            // purpose. TL and the animated BL merge behavior stay untouched.
            topRightRadius: 0
        }

        PanelBg {
            id: osdBg

            panel: panels.osdWrapper
            deformAmount: 0.25
            x: panels.osdWrapper.x + panels.osd.x + root.borderThickness
            implicitWidth: panels.osd.width
        }

        PanelBg {
            id: notifsBg

            panel: panels.notifications
            // R-custom: user request 2026-08-08 — flat connection where the
            // panel meets the screen edge / bar-at-edge junction; proven lever
            // from the 2026-08-08 notch fix rung 3; cornerFill:false +
            // invisibleEdgePush 42 + hidden-sidebar excludes left untouched on
            // purpose. TL/BL float free and keep their rounding.
            topRightRadius: 0
            bottomRightRadius: 0
        }

        PanelBg {
            id: utilsBg

            panel: panels.utilities
            deformAmount: panels.sidebar.visible ? 0.1 : 0.15
            exclude: panels.sidebar.offsetScale > 0.08 ? [] : [sidebarBg]
            topLeftRadius: Math.max(0, Math.min(1, panels.sidebar.offsetScale / 0.3)) * radius
            // R-custom: user-authorized flat corner ("just make it flat or
            // remove it" — SESSION_HANDOFF.md:27-28); kills the notch
            // deterministically — no arc left for the smin bridge to crease.
            // The artifact at this screen-flush br corner survived push 42 (T4)
            // and cornerFill:false (T5), both proven geometrically incapable
            // (near-border test needs push > 60, kFrame caps at 45; cornerFill
            // factor already clamped to 1 at this corner). Utilities br corner
            // carries the same screen-corner-flush artifact class
            // (v2-utilities-br intrusion 34px, visually confirmed).
            bottomRightRadius: 0
            // R-custom: user request 2026-08-08 — flat connection where the
            // panel meets the screen edge / bar-at-edge junction; proven lever
            // from the 2026-08-08 notch fix rung 3; cornerFill:false +
            // invisibleEdgePush 42 + hidden-sidebar excludes left untouched on
            // purpose. BL additionally per user report: the quick-toggle bar's
            // bottom-left looked "messed up / not fully connected to the
            // bottom of the screen" — squaring it seats the panel flat on the
            // bottom edge. The animated topLeftRadius sidebar-merge above
            // stays untouched.
            topRightRadius: 0
            bottomLeftRadius: 0
        }

        PanelBg {
            id: popoutBg

            // Extra height to prevent horizontal movement deformation partially detaching panel from bar
            property real extraHeight: panels.popouts.isDetached ? 0 : 0.2

            panel: panels.popoutsWrapper
            deformAmount: panels.popouts.isDetached ? 0.05 : panels.popouts.hasCurrent ? 0.15 : 0.1
            x: panels.popoutsWrapper.x + panels.popouts.x + root.borderThickness
            y: panels.popoutsWrapper.y + panels.popouts.y + bar.implicitHeight - panels.popouts.height * extraHeight
            implicitWidth: panels.popouts.width
            implicitHeight: panels.popouts.height * (1 + extraHeight)
            // R-custom: user request 2026-08-08 — flat connection where the
            // panel meets the screen edge / bar-at-edge junction; proven lever
            // from the 2026-08-08 notch fix rung 3; cornerFill:false +
            // invisibleEdgePush 42 + hidden-sidebar excludes left untouched on
            // purpose. Flush-right test: ClipWrapper right-clamps so
            // x + width lands in [root.width, root.width + 1) when the popout
            // touches the edge (shell/modules/bar/popouts/ClipWrapper.qml:25-34);
            // -1 = inherit the shape radius (blobrect.cpp:160-167) so
            // floating/centered/detached popouts keep full rounding. Reading
            // own x/implicitWidth in these bindings is loop-free since radius
            // never affects geometry.
            topRightRadius: x + implicitWidth >= root.width - 1 ? 0 : -1
            bottomRightRadius: x + implicitWidth >= root.width - 1 ? 0 : -1

            Behavior on extraHeight {
                Anim {}
            }
        }
    }

    Interactions {
        id: interactions

        screen: root.screen
        popouts: panels.popouts
        screenState: root.screenState
        panels: panels
        bar: bar
        borderThickness: root.borderLayoutThickness
        fullscreen: root.hasFullscreen

        Panels {
            id: panels

            screen: root.screen
            screenState: root.screenState
            bar: bar
            borderThickness: root.borderThickness

            utilities.horizontalStretch: (sidebarBg.rawDeformMatrix.m11 - 1) / 2 + 1
            utilities.deformMatrix: utilsBg.rawDeformMatrix

            dashboard.transform: Matrix4x4 {
                matrix: dashBg.deformMatrix
            }
            launcher.transform: Matrix4x4 {
                matrix: launcherBg.deformMatrix
            }
            session.transform: Matrix4x4 {
                matrix: sessionBg.deformMatrix
            }
            sidebar.transform: Matrix4x4 {
                matrix: sidebarBg.deformMatrix
            }
            osd.transform: Matrix4x4 {
                matrix: osdBg.deformMatrix
            }
            notifications.transform: Matrix4x4 {
                matrix: notifsBg.deformMatrix
            }
            utilities.transform: Matrix4x4 {
                matrix: utilsBg.deformMatrix
            }
            popouts.transform: Matrix4x4 {
                matrix: popoutBg.deformMatrix
            }
        }

        BarWrapper {
            id: bar

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            screen: root.screen
            screenState: root.screenState
            popouts: panels.popouts

            fullscreen: root.hasFullscreen
        }
    }

    ShellState.ComponentRef {
        screen: root.screen
        slot: "rootWindow"
        component: root
    }

    ShellState.ComponentRef {
        screen: root.screen
        slot: "interactionWrapper"
        component: interactions
    }

    ShellState.ComponentRef {
        screen: root.screen
        slot: "bar"
        component: bar
    }

    ShellState.ComponentRef {
        screen: root.screen
        slot: "panels"
        component: panels
    }

    component PanelBg: BlobRect {
        required property Item panel
        property real deformAmount: 0.15

        group: blobGroup
        x: panel.x + root.borderThickness
        y: panel.y + bar.implicitHeight
        implicitWidth: panel.width
        implicitHeight: panel.height
        radius: Tokens.rounding.extraLarge
        deformScale: (deformAmount * Config.appearance.deformScale) / 10000
    }
}
