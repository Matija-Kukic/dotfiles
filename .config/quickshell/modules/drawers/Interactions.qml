import QtQuick
import QtQuick.Controls
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.modules.bar as Bar
import qs.modules.bar.popouts as BarPopouts

CustomMouseArea {
    id: root

    required property ShellScreen screen
    required property BarPopouts.Wrapper popouts
    required property ScreenState screenState
    required property Panels panels
    required property Bar.BarWrapper bar
    required property real borderThickness
    required property bool fullscreen

    property point dragStart
    property bool dashboardShortcutActive
    property bool osdShortcutActive
    property bool utilitiesShortcutActive

    // True when hovering the ActiveWindow title in the bar while its small
    // window-info popout is disabled — treated as a dashboard-hover then.
    function overActiveWindowTitle(x: real, y: real): bool {
        return !Config.bar.popouts.activeWindow && y < bar.implicitHeight && bar.entryIdAt(x) === "activeWindow";
    }

    function withinPanelHeight(panel: Item, x: real, y: real): bool {
        const panelY = bar.implicitHeight + panel.y;
        return y >= panelY - Config.border.rounding && y <= panelY + panel.height + Config.border.rounding;
    }

    function withinPanelWidth(panel: Item, x: real, y: real): bool {
        const panelX = root.borderThickness + panel.x;
        return x >= panelX - Config.border.rounding && x <= panelX + panel.width + Config.border.rounding;
    }

    function inRightPanel(panel: Item, x: real, y: real): bool {
        return x > Math.min(width - Config.border.minThickness, root.borderThickness + panel.x) && withinPanelHeight(panel, x, y);
    }

    // R-custom: geometric exclusion (plan fix-visual-defects task-3) —
    // closing-side helper invoked by the screenState Connections above.
    // If the named panel is just open AND the currently-displayed popout
    // (if any) shares horizontal space, set popouts.hasCurrent = false so
    // the popout closes. Safe to call with no popout (hasCurrent stays false).
    function _closeOverlappingPopout(name: string): void {
        if (!popouts?.hasCurrent) return;
        // Reconstruct the would-be popout x-range from the live popouts
        // geometry: the popout is centered under currentCenter, with
        // nonAnimWidth. Read its actual width (post-current popout load).
        const popoutW = popouts.nonAnimWidth ?? 0;
        if (popoutW <= 0) return;
        const popoutCenter = popouts.currentCenter;
        // Map the same ClipWrapper clamp the open-path uses, via Panels.
        const popoutRect = panels.popoutXRange(popoutCenter, popoutW);
        // R-custom: task-4 signature propagation — the panel-open close side
        // keeps counting notifications (includeNotifs=true), preserving
        // task-3's semantics: notifications still clear/block popouts.
        const others = panels.openPanelXRanges(name, true);
        for (const o of others) {
            if (panels.xRangesOverlap(popoutRect, o)) {
                popouts.hasCurrent = false;
                bar.closeTray();
                return;
            }
        }
    }

    function inTopPanel(panel: Item, x: real, y: real): bool {
        const panelHeight = panel.height * (1 - (panel.offsetScale ?? 0)); // qmllint disable missing-property
        return y >= bar.implicitHeight && y < bar.implicitHeight + Math.max(Config.border.minThickness, Config.border.thickness + panelHeight) && withinPanelWidth(panel, x, y);
    }

    function inBottomPanel(panel: Item, x: real, y: real, isCorner = false): bool {
        const panelHeight = panel.height * (1 - (panel.offsetScale ?? 0)); // qmllint disable missing-property
        return y > height - Math.max(Config.border.minThickness, Config.border.thickness + panelHeight) - (isCorner ? Config.border.rounding : 0) && withinPanelWidth(panel, x, y);
    }

    function onWheel(event: WheelEvent): void {
        if (fullscreen)
            return;
        if (event.y < bar.implicitHeight) {
            bar.handleWheel(event.x, event.angleDelta);
        }
    }

    anchors.fill: parent
    acceptedButtons: fullscreen ? Qt.NoButton : Qt.AllButtons
    hoverEnabled: true

    onPressed: event => dragStart = Qt.point(event.x, event.y)
    onContainsMouseChanged: {
        if (!containsMouse) {
            // Only hide if not activated by shortcut
            if (!osdShortcutActive) {
                screenState.osd = false;
                root.panels.osd.hovered = false;
            }

            if (!dashboardShortcutActive)
                screenState.dashboard = false;

            if (!utilitiesShortcutActive)
                screenState.utilities = false;

            if (!popouts.currentName.startsWith("traymenu") || ((popouts.current as StackView)?.depth ?? 0) <= 1) {
                popouts.hasCurrent = false;
                bar.closeTray();
            }

            if (Config.bar.showOnHover)
                bar.isHovered = false;

            if (Config.sidebar.showOnHover)
                screenState.sidebar = false;
        }
    }

    onPositionChanged: event => {
        if (popouts.isDetached)
            return;

        const x = event.x;
        const y = event.y;
        const dragX = x - dragStart.x;
        const dragY = y - dragStart.y;

        if (fullscreen) {
            root.panels.osd.hovered = inRightPanel(panels.osdWrapper, x, y);
            return;
        }

        // Show bar in non-exclusive mode on hover
        if (!screenState.bar && Config.bar.showOnHover && y < bar.clampedHeight)
            bar.isHovered = true;

        // Show/hide bar on drag
        if (pressed && dragStart.y < bar.clampedHeight) {
            if (dragY > Config.bar.dragThreshold)
                screenState.bar = true;
            else if (dragY < -Config.bar.dragThreshold)
                screenState.bar = false;
        }

        if (panels.sidebar.offsetScale === 1) {
            // Show osd on hover
            const showOsd = inRightPanel(panels.osdWrapper, x, y);

            // Always update visibility based on hover if not in shortcut mode
            if (!osdShortcutActive) {
                screenState.osd = showOsd;
                root.panels.osd.hovered = showOsd;
            } else if (showOsd) {
                // If hovering over OSD area while in shortcut mode, transition to hover control
                osdShortcutActive = false;
                root.panels.osd.hovered = true;
            }

            const showSidebar = pressed && dragStart.x > Math.min(width - Config.border.minThickness, root.borderThickness + panels.sidebar.x);

            // Show sidebar on hover (top-right corner, bounded by notification panel height)
            if (Config.sidebar.showOnHover) {
                const sidebarTriggerY = Math.max(Config.sidebar.minHoverThreshold, panels.notifications.y + panels.notifications.height + bar.implicitHeight);
                const showSidebarHover = x > Math.min(width - Config.border.minThickness, root.borderThickness + panels.sidebar.x) && y <= sidebarTriggerY;
                if (showSidebarHover && !screenState.sidebar)
                    screenState.sidebar = true;
            }

            // Show/hide session on drag (session is a top panel in the topbar variant)
            if (pressed && inTopPanel(panels.sessionWrapper, dragStart.x, dragStart.y) && withinPanelWidth(panels.sessionWrapper, x, y)) {
                if (dragY > Config.session.dragThreshold) {
                    // R-custom: geometric exclusion (plan fix-visual-defects
                    // task-3) — only open if x-disjoint from other open panels.
                    if (!screenState.session && (panels.canOpenPanel("session") || !panels.sessionWrapper.width))
                        screenState.session = true;
                } else if (dragY < -Config.session.dragThreshold)
                    screenState.session = false;

                // Show sidebar on drag if in session area and session is nearly fully visible
                if (showSidebar && panels.session.offsetScale <= 0 && dragX < -Config.sidebar.dragThreshold)
                    screenState.sidebar = true;
            } else if (showSidebar && dragX < -Config.sidebar.dragThreshold) {
                // Show sidebar on drag if not in session area
                screenState.sidebar = true;
            }
        } else {
            const outOfSidebar = x < width - panels.sidebar.width * (1 - panels.sidebar.offsetScale);
            // Show osd on hover
            const showOsd = outOfSidebar && inRightPanel(panels.osdWrapper, x, y);

            // Always update visibility based on hover if not in shortcut mode
            if (!osdShortcutActive) {
                screenState.osd = showOsd;
                root.panels.osd.hovered = showOsd;
            } else if (showOsd) {
                // If hovering over OSD area while in shortcut mode, transition to hover control
                osdShortcutActive = false;
                root.panels.osd.hovered = true;
            }

            // Show/hide session on drag (session is a top panel in the topbar variant)
            if (pressed && outOfSidebar && inTopPanel(panels.sessionWrapper, dragStart.x, dragStart.y) && withinPanelWidth(panels.sessionWrapper, x, y)) {
                if (dragY > Config.session.dragThreshold) {
                    // R-custom: geometric exclusion — only open if x-disjoint.
                    if (!screenState.session && (panels.canOpenPanel("session") || !panels.sessionWrapper.width))
                        screenState.session = true;
                } else if (dragY < -Config.session.dragThreshold)
                    screenState.session = false;
            }

            // Show/hide sidebar on hover
            if (Config.sidebar.showOnHover && !pressed) {
                const sidebarTriggerY = Math.max(Config.sidebar.minHoverThreshold, panels.notifications.y + panels.notifications.height + bar.implicitHeight);
                const showSidebarHover = x > Math.min(width - Config.border.minThickness, root.borderThickness + panels.sidebar.x) && y <= sidebarTriggerY;
                if (showSidebarHover && !screenState.sidebar) {
                    screenState.sidebar = true;
                } else {
                    const inSidebarArea = inRightPanel(panels.sidebar, x, y) || inTopPanel(panels.sessionWrapper, x, y);
                    if (!inSidebarArea)
                        screenState.sidebar = false;
                }
            }

            // Hide sidebar on drag
            if (pressed && inRightPanel(panels.sidebar, dragStart.x, 0) && dragX > Config.sidebar.dragThreshold)
                screenState.sidebar = false;
        }

        // Show launcher on hover, or show/hide on drag if hover is disabled
        if (Config.launcher.showOnHover) {
            if (!screenState.launcher && inTopPanel(panels.launcher, x, y)) {
                // R-custom: geometric exclusion — only open launcher if x-disjoint
                // from another open panel (notably dashboard).
                if (panels.canOpenPanel("launcher") || !panels.launcher.width)
                    screenState.launcher = true;
            }
        } else if (pressed && inTopPanel(panels.launcher, dragStart.x, dragStart.y) && withinPanelWidth(panels.launcher, x, y)) {
            if (dragY > Config.launcher.dragThreshold) {
                // R-custom: geometric exclusion — drag-to-open also gated.
                if (!screenState.launcher && (panels.canOpenPanel("launcher") || !panels.launcher.width))
                    screenState.launcher = true;
            } else if (dragY < -Config.launcher.dragThreshold)
                screenState.launcher = false;
        }

        // Show dashboard on hover (also when hovering the ActiveWindow title in the
        // bar if the small window-info popout is disabled)
        const showDashboard = (Config.dashboard.showOnHover && inTopPanel(panels.dashboard, x, y)) || overActiveWindowTitle(x, y);

        // Always update visibility based on hover if not in shortcut mode
        if (!dashboardShortcutActive) {
            // R-custom: geometric exclusion — dashboard's hover-driven
            // `= true` is gated. `= false` is left free (closing always allowed)
            // and the activeWindow-title route is left alone — the user already
            // has to be on the bar trigger area for that to fire, and Bar.qml
            // checkPopout already refuses popouts there; the dashboard here is
            // an explicit user gesture so it's safe to gate consistently.
            if (showDashboard && !screenState.dashboard
                    && !panels.canOpenPanel("dashboard") && panels.dashboard.width > 0) {
                // Blocked: keep dashboard closed.
            } else {
                screenState.dashboard = showDashboard;
            }
        } else if (showDashboard) {
            // If hovering over dashboard area while in shortcut mode, transition to hover control
            dashboardShortcutActive = false;
        }

        // Show/hide dashboard on drag (for touchscreen devices)
        if (pressed && inTopPanel(panels.dashboard, dragStart.x, dragStart.y) && withinPanelWidth(panels.dashboard, x, y)) {
            if (dragY > Config.dashboard.dragThreshold) {
                // R-custom: geometric exclusion — drag-to-open also gated.
                if (!screenState.dashboard && (panels.canOpenPanel("dashboard") || !panels.dashboard.width))
                    screenState.dashboard = true;
            } else if (dragY < -Config.dashboard.dragThreshold)
                screenState.dashboard = false;
        }

        // Show utilities on hover
        const showUtilities = inBottomPanel(panels.utilities, x, y, true);

        // Always update visibility based on hover if not in shortcut mode
        if (!utilitiesShortcutActive) {
            // R-custom: plan quicksettings-notif-merge task-3 — launcher HARD
            // block, OPEN-direction only: hover may CLOSE utilities anytime
            // (showUtilities false → false), but may only OPEN it while the
            // launcher is closed.
            screenState.utilities = showUtilities && (screenState.utilities || panels.launcher.offsetScale >= 1);
        } else if (showUtilities) {
            // If hovering over utilities area while in shortcut mode, transition to hover control
            utilitiesShortcutActive = false;
        }

        // Show popouts on hover
        if (y < bar.implicitHeight) {
            bar.checkPopout(x);
        } else if ((!popouts.currentName.startsWith("traymenu") || ((popouts.current as StackView)?.depth ?? 0) <= 1) && !inTopPanel(panels.popoutsWrapper, x, y)) {
            popouts.hasCurrent = false;
            bar.closeTray();
        }
    }

    // Monitor individual visibility changes
    Connections {
        function onLauncherChanged() {
            // If launcher is hidden, clear shortcut flags for dashboard and OSD
            if (!root.screenState.launcher) {
                root.dashboardShortcutActive = false;
                root.osdShortcutActive = false;
                root.utilitiesShortcutActive = false;

                // Also hide dashboard and OSD if they're not being hovered
                const inDashboardArea = root.inTopPanel(root.panels.dashboard, root.mouseX, root.mouseY) || root.overActiveWindowTitle(root.mouseX, root.mouseY);
                const inOsdArea = root.inRightPanel(root.panels.osdWrapper, root.mouseX, root.mouseY);

                if (!inDashboardArea) {
                    root.screenState.dashboard = false;
                }
                if (!inOsdArea) {
                    root.screenState.osd = false;
                    root.panels.osd.hovered = false;
                }
            } else {
                // R-custom: plan quicksettings-notif-merge task-3 — launcher
                // WINS unconditionally: the moment it opens, kill ANY active
                // popout (not just geometrically-overlapping ones — the
                // launcher's maxHeight ≈ full screen, so on small screens it
                // overlaps everything) and close the utilities panel. This
                // replaces the geometric `_closeOverlappingPopout("launcher")`
                // for the launcher case; the helper stays for the OTHER
                // panels' handlers (dashboard/session) which keep geometric
                // close semantics.
                root.popouts.hasCurrent = false;
                root.bar.closeTray();
                root.screenState.utilities = false;
            }
        }

        function onDashboardChanged() {
            if (root.screenState.dashboard) {
                // Dashboard became visible, immediately check if this should be shortcut mode
                const inDashboardArea = root.inTopPanel(root.panels.dashboard, root.mouseX, root.mouseY) || root.overActiveWindowTitle(root.mouseX, root.mouseY);
                if (!inDashboardArea) {
                    root.dashboardShortcutActive = true;
                }
                // R-custom: geometric exclusion (plan fix-visual-defects
                // task-3) — closing side: if dashboard just opened, kill
                // any active popout whose x-range overlaps it.
                root._closeOverlappingPopout("dashboard");
            } else {
                // Dashboard hidden, clear shortcut flag
                root.dashboardShortcutActive = false;
            }
        }

        function onSessionChanged() {
            // R-custom: geometric exclusion — closing side. If the session
            // just opened, kill any active popout whose x-range overlaps
            // its right-edge column. IPC-opens (no cursor move) are the
            // primary trigger; `qs ipc call drawers toggle session` lands
            // here when the user wants the overlap-clear.
            if (root.screenState.session)
                root._closeOverlappingPopout("session");
        }

        function onOsdChanged() {
            if (root.screenState.osd) {
                // OSD became visible, immediately check if this should be shortcut mode
                const inOsdArea = root.inRightPanel(root.panels.osdWrapper, root.mouseX, root.mouseY);
                if (!inOsdArea) {
                    root.osdShortcutActive = true;
                }
            } else {
                // OSD hidden, clear shortcut flag
                root.osdShortcutActive = false;
            }
        }

        function onUtilitiesChanged() {
            if (root.screenState.utilities) {
                // Utilities became visible, immediately check if this should be shortcut mode
                const inUtilitiesArea = root.inBottomPanel(root.panels.utilities, root.mouseX, root.mouseY);
                if (!inUtilitiesArea) {
                    root.utilitiesShortcutActive = true;
                }
            } else {
                // Utilities hidden, clear shortcut flag
                root.utilitiesShortcutActive = false;
            }
        }

        target: root.screenState
    }
}
