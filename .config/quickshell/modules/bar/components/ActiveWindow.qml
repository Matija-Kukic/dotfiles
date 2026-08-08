pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

// Horizontal active-window entry: app icon + elided title, crossfading.
Item {
    id: root

    required property var bar
    required property Brightness.Monitor monitor
    property color colour: Colours.palette.m3primary

    readonly property string windowTitle: {
        const title = Hypr.activeToplevel?.title;
        if (!title)
            return qsTr("Desktop");
        if (Config.bar.activeWindow.compact) {
            // " - " (standard hyphen), " — " (em dash), " – " (en dash)
            const parts = title.split(/\s+[\-\u2013\u2014]\s+/);
            if (parts.length > 1)
                return parts[parts.length - 1].trim();
        }
        return title;
    }

    readonly property int maxWidth: {
        // Title is a centered overlay (see Bar.qml): measure the in-layout
        // entries and cap hard so long titles stay compact
        const entries = bar.layoutRow.children.filter(c => c.entryId && c.entryId !== "spacer");
        const otherWidth = entries.reduce((acc, curr) => acc + (curr.item?.nonAnimWidth ?? curr.width ?? 0), 0);
        return Math.min(bar.width - otherWidth - bar.layoutRow.spacing * (bar.layoutRow.children.length - 1) - bar.hPadding * 2, 360);
    }
    property Title current: text1

    clip: true
    implicitWidth: icon.implicitWidth + titleHolder.implicitWidth + Tokens.spacing.small
    implicitHeight: icon.implicitHeight

    Loader {
        asynchronous: true
        anchors.fill: parent
        active: !Config.bar.activeWindow.showOnHover

        sourceComponent: MouseArea {
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onPositionChanged: {
                const popouts = root.bar.popouts;
                if (popouts.hasCurrent && popouts.currentName !== "activewindow")
                    popouts.hasCurrent = false;
            }
            onClicked: {
                const popouts = root.bar.popouts;
                if (popouts.hasCurrent) {
                    popouts.hasCurrent = false;
                } else {
                    popouts.currentName = "activewindow";
                    popouts.currentCenter = root.mapToItem(root.bar, root.implicitWidth / 2, 0).x;
                    popouts.hasCurrent = true;
                }
            }
        }
    }

    MaterialIcon {
        id: icon

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        animate: true
        text: Icons.getAppCategoryIcon(Hypr.activeToplevel?.lastIpcObject.class, "desktop_windows")
        color: root.colour
    }

    Item {
        id: titleHolder

        anchors.left: icon.right
        anchors.leftMargin: Tokens.spacing.small
        anchors.verticalCenter: parent.verticalCenter

        // Track only the current title's width: the centred texts crossfade in
        // place and the block re-centres instantly (no width animation), so the
        // title never visibly slides to compensate for length changes. The old
        // title may overflow during its fade-out — root clips it.
        implicitWidth: root.current.implicitWidth
        implicitHeight: text1.implicitHeight

        Title {
            id: text1
        }

        Title {
            id: text2
        }
    }

    TextMetrics {
        id: metrics

        text: root.windowTitle
        font: root.Tokens.font.body.builders.small.letterSpacing(1.4).build()
        elide: Qt.ElideRight
        elideWidth: root.maxWidth - icon.implicitWidth - Tokens.spacing.small

        onTextChanged: {
            const next = root.current === text1 ? text2 : text1;
            next.text = elidedText;
            root.current = next;
        }
        onElideWidthChanged: root.current.text = elidedText
    }

    component Title: StyledText {
        id: text

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        font: metrics.font
        color: root.colour
        opacity: root.current === this ? 1 : 0

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }
}
