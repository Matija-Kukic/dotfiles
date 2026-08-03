import Quickshell
import QtQuick
import qs.common
import "modules/bar"
import "modules/minibar"

ShellRoot {
    id: root

    // Live-reload the shell when QML files change (dev convenience)
    settings.watchFiles: true

    Loader {
        active: Config.barVariant === "full"
        sourceComponent: Bar {}
    }

    Loader {
        active: Config.barVariant !== "full"
        sourceComponent: MiniBar {}
    }
}
