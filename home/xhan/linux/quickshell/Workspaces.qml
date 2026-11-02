// Hyprland workspaces of one monitor. The focused one is highlighted;
// clicking a workspace switches to it.
import QtQuick
import Quickshell.Hyprland

Row {
    id: root

    required property HyprlandMonitor monitor

    spacing: 4

    Repeater {
        model: Hyprland.workspaces.values.filter(ws => ws.id > 0 && ws.monitor === root.monitor)

        Rectangle {
            id: workspace

            required property HyprlandWorkspace modelData
            readonly property bool isActive: modelData.active
            readonly property bool isOccupied: modelData.toplevels.values.length > 0

            width: isActive ? 32 : 22
            height: 22
            radius: 11
            color: isActive ? Theme.mauve : (mouse.containsMouse ? Theme.surface1 : Theme.surface0)

            Behavior on width {
                NumberAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: workspace.modelData.name
                color: workspace.isActive ? Theme.base : (workspace.isOccupied ? Theme.text : Theme.overlay0)
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: workspace.isActive
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: workspace.modelData.activate()
            }
        }
    }
}
