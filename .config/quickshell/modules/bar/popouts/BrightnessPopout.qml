pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

// Brightness popout: horizontal slider matching the OSD/sidebar widgets
ColumnLayout {
    id: root

    readonly property var monitor: Brightness.monitors.find(m => !m.isDdc) ?? Brightness.monitors[0] ?? null

    spacing: Tokens.spacing.medium

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        text: root.monitor ? qsTr("Brightness: %1%").arg(Math.round(root.monitor.brightness * 100)) : qsTr("No brightness control detected")
    }

    CustomMouseArea {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: Tokens.sizes.osd.sliderHeight
        implicitHeight: Tokens.sizes.osd.sliderWidth

        function onWheel(event: WheelEvent) {
            if (!root.monitor)
                return;
            if (event.angleDelta.y > 0)
                root.monitor.setBrightness(root.monitor.brightness + GlobalConfig.services.brightnessIncrement);
            else if (event.angleDelta.y < 0)
                root.monitor.setBrightness(root.monitor.brightness - GlobalConfig.services.brightnessIncrement);
        }

        FilledSlider {
            anchors.fill: parent
            orientation: Qt.Horizontal

            icon: `brightness_${(Math.round(value * 6) + 1)}`
            value: root.monitor?.brightness ?? 0
            onMoved: root.monitor?.setBrightness(value)
        }
    }
}
