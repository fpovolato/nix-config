// Top bar for one screen: workspaces and window title on the left, clock in
// the middle, tray and volume on the right.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: bar

    required property var modelData
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

    screen: modelData
    color: "transparent"
    implicitHeight: Theme.barHeight + 8

    // Hyprland blurs this namespace (hyprland/windowrules.lua).
    WlrLayershell.namespace: "quickshell-bar"

    anchors {
        top: true
        left: true
        right: true
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        radius: Theme.radius
        color: Qt.alpha(Theme.base, 0.8)
        border.color: Theme.surface0
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing
            anchors.rightMargin: Theme.spacing
            spacing: Theme.spacing * 2

            Workspaces {
                monitor: bar.monitor
            }

            ActiveWindow {
                monitor: bar.monitor
                Layout.fillWidth: true
            }

            Tray {
                window: bar
            }

            Volume {}
        }

        Clock {
            anchors.centerIn: parent
        }
    }
}
