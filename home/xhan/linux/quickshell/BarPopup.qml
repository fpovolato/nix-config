// Card that drops down under a bar widget. Clicking outside the popup and
// the bar closes it; clicking the widget again toggles it.
import QtQuick
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: root

    required property Item target
    required property QsWindow barWindow
    property int contentWidth: 360
    default property alias content: column.data

    function toggle() {
        visible = !visible;
    }

    anchor.item: target
    anchor.rect.x: target.width / 2
    anchor.rect.y: target.height + 14
    anchor.gravity: Edges.Bottom

    color: "transparent"
    implicitWidth: card.width
    implicitHeight: card.height

    HyprlandFocusGrab {
        active: root.visible
        windows: [root, root.barWindow]
        onCleared: root.visible = false
    }

    Rectangle {
        id: card

        width: root.contentWidth
        height: column.implicitHeight + 32
        radius: Theme.radius + 4
        color: Theme.base
        border.color: Theme.surface0
        border.width: 1

        Column {
            id: column

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 10
        }
    }
}
