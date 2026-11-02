// StatusNotifierItem system tray. Left click activates an item, right click
// opens its menu.
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Row {
    id: root

    required property QsWindow window

    spacing: 6

    Repeater {
        model: SystemTray.items.values

        IconImage {
            id: icon

            required property SystemTrayItem modelData

            implicitSize: 18
            source: modelData.icon

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton || icon.modelData.onlyMenu) {
                        if (icon.modelData.hasMenu) {
                            const pos = icon.mapToItem(root.window.contentItem, 0, icon.height);
                            icon.modelData.display(root.window, pos.x, pos.y);
                        }
                    } else {
                        icon.modelData.activate();
                    }
                }
            }
        }
    }
}
