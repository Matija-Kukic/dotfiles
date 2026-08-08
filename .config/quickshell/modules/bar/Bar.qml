pragma ComponentBehavior: Bound

import "popouts" as BarPopouts
import "components"
import "components/workspaces"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

// Horizontal topbar: entries laid out left→right in an inner RowLayout;
// the ActiveWindow title is an overlay anchored to the true bar center
// (side groups have unequal widths, so in-layout centering is off).
Item {
    id: root

    required property ShellScreen screen
    required property ScreenState screenState
    required property BarPopouts.Wrapper popouts
    required property bool fullscreen
    readonly property int hPadding: Tokens.padding.large
    readonly property alias layoutRow: layoutRow
    implicitHeight: layoutRow.implicitHeight

    function closeTray(): void {
        if (!Config.bar.tray.compact)
            return;

        for (let i = 0; i < repeater.count; i++) {
            const tray = (repeater.itemAt(i) as EntryWrapper).item as Tray;
            if (tray)
                tray.expanded = false;
        }
    }

    // pos = x along the bar; returns the entry id at that position ("" if none)
    function entryIdAt(pos: real): string {
        if (awOverlay.item && pos >= awOverlay.x && pos <= awOverlay.x + awOverlay.width)
            return "activeWindow";
        const ch = layoutRow.childAt(pos, height / 2) as EntryWrapper;
        return ch?.entryId ?? "";
    }

    // pos = x along the bar
    function checkPopout(pos: real): void {
        const ch = layoutRow.childAt(pos, height / 2) as EntryWrapper;

        if (ch?.entryId !== "tray")
            closeTray();

        if (!ch) {
            popouts.hasCurrent = false;
            return;
        }

        const id = ch.entryId;
        const left = ch.x;

        if (id === "statusIcons" && Config.bar.popouts.statusIcons) {
            const items = (ch.item as StatusIcons).items;
            const icon = items.childAt(mapToItem(items, pos, 0).x, items.height / 2);
            if (icon) {
                popouts.currentName = icon.name;
                popouts.currentCenter = Qt.binding(() => icon.mapToItem(root, icon.implicitWidth / 2, 0).x);
                popouts.hasCurrent = true;
            }
        } else if (id === "tray" && Config.bar.popouts.tray) {
            const tray = ch.item as Tray;
            if (!Config.bar.tray.compact || (tray.expanded && !tray.expandIcon.contains(mapToItem(tray.expandIcon, pos, tray.implicitHeight / 2)))) {
                const index = Math.floor(((pos - left - tray.padding * 2 + tray.spacing) / tray.layout.implicitWidth) * tray.items.count);
                const trayItem = tray.items.itemAt(index);
                if (trayItem) {
                    popouts.currentName = `traymenu${index}`;
                    popouts.currentCenter = Qt.binding(() => trayItem.mapToItem(root, trayItem.implicitWidth / 2, 0).x);
                    popouts.hasCurrent = true;
                } else {
                    popouts.hasCurrent = false;
                }
            } else {
                popouts.hasCurrent = false;
                tray.expanded = true;
            }
        } else if (id === "activeWindow") {
            if (Config.bar.popouts.activeWindow && Config.bar.activeWindow.showOnHover) {
                popouts.currentName = id.toLowerCase();
                popouts.currentCenter = (ch.item as Item).mapToItem(root, (ch.item as Item).implicitWidth / 2, 0).x ?? 0;
                popouts.hasCurrent = true;
            } else {
                // Small window-info popout disabled: hovering the title opens the dashboard instead (see Interactions.qml)
                popouts.hasCurrent = false;
            }
        }
    }

    // pos = x along the bar
    function handleWheel(pos: real, angleDelta: point): void {
        const ch = layoutRow.childAt(pos, height / 2) as EntryWrapper;
        if (ch?.entryId === "workspaces" && Config.bar.scrollActions.workspaces) {
            // Workspace scroll
            const mon = (GlobalConfig.bar.workspaces.perMonitorWorkspaces ? Hypr.monitorFor(screen) : Hypr.focusedMonitor);
            const specialWs = mon?.lastIpcObject.specialWorkspace.name;
            if (specialWs?.length > 0)
                Hypr.dispatch(Hypr.usingLua ? `hl.dsp.workspace.toggle_special("${specialWs.slice(8)}")` : `togglespecialworkspace ${specialWs.slice(8)}`);
            else if (angleDelta.y < 0 || (GlobalConfig.bar.workspaces.perMonitorWorkspaces ? mon.activeWorkspace?.id : Hypr.activeWsId) > 1)
                Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ workspace = "r${angleDelta.y > 0 ? "-" : "+"}1" })` : `workspace r${angleDelta.y > 0 ? "-" : "+"}1`);
        } else if (pos < screen.width / 2 && Config.bar.scrollActions.volume) {
            // Volume scroll on left half
            if (angleDelta.y > 0)
                Audio.incrementVolume();
            else if (angleDelta.y < 0)
                Audio.decrementVolume();
        } else if (Config.bar.scrollActions.brightness) {
            // Brightness scroll on right half
            const monitor = Brightness.getMonitorForScreen(screen);
            if (angleDelta.y > 0)
                monitor.setBrightness(monitor.brightness + GlobalConfig.services.brightnessIncrement);
            else if (angleDelta.y < 0)
                monitor.setBrightness(monitor.brightness - GlobalConfig.services.brightnessIncrement);
        }
    }

    RowLayout {
        id: layoutRow

        anchors.fill: parent
        spacing: Tokens.spacing.medium

        Repeater {
            id: repeater

            model: ScriptModel {
                values: root.Config.bar.entries.values.filter(e => e.enabled)
            }

            DelegateChooser {
                role: "id"

                DelegateChoice {
                    roleValue: "spacer"
                    delegate: EntryWrapper {
                        Layout.fillWidth: true
                    }
                }
                DelegateChoice {
                    roleValue: "logo"
                    delegate: EntryWrapper {
                        OsIcon {
                            objectName: "taskbarLogo"
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "workspaces"
                    delegate: EntryWrapper {
                        Workspaces {
                            objectName: "taskbarWorkspaces"
                            screen: root.screen
                            fullscreen: root.fullscreen
                        }
                    }
                }
                DelegateChoice {
                    // Zero-size placeholder: the title renders via the centered awOverlay below
                    roleValue: "activeWindow"
                    delegate: Item {}
                }
                DelegateChoice {
                    roleValue: "tray"
                    delegate: EntryWrapper {
                        Tray {
                            objectName: "taskbarTray"
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "clock"
                    delegate: EntryWrapper {
                        Clock {
                            objectName: "taskbarClock"
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "statusIcons"
                    delegate: EntryWrapper {
                        StatusIcons {
                            objectName: "taskbarStatusIcons"
                            screen: root.screen
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "power"
                    delegate: EntryWrapper {
                        Power {
                            objectName: "taskbarPowerButton"
                            screenState: root.screenState
                        }
                    }
                }
            }
        }
    }

    // True-center ActiveWindow title overlay (not affected by unequal side groups)
    Loader {
        id: awOverlay

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        active: root.Config.bar.entries.values.some(e => e.id === "activeWindow" && e.enabled)

        sourceComponent: ActiveWindow {
            objectName: "taskbarActiveWindow"
            bar: root
            monitor: Brightness.getMonitorForScreen(root.screen)
        }
    }

    component EntryWrapper: Item {
        required property var modelData
        required property int index
        default property Item item
        readonly property string entryId: modelData.id

        Layout.leftMargin: index === 0 ? root.hPadding : 0
        Layout.rightMargin: index === repeater.count - 1 ? root.hPadding : 0
        Layout.alignment: Qt.AlignVCenter

        implicitWidth: item?.implicitWidth ?? 0
        implicitHeight: item?.implicitHeight ?? 0

        children: item
    }
}
