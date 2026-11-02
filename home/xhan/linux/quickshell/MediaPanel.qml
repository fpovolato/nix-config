// Player card: cover, track, seekable progress bar and transport controls.
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

BarPopup {
    id: root

    property MprisPlayer player

    contentWidth: 380

    function time(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    Row {
        width: parent.width
        spacing: 14

        ClippingRectangle {
            id: cover

            width: 96
            height: 96
            radius: Theme.radius
            color: Theme.surface0

            Image {
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                sourceSize: Qt.size(192, 192)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                visible: !root.player?.trackArtUrl
                text: "󰝚"
                color: Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: 36
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.player?.canRaise ?? false
                cursorShape: Qt.PointingHandCursor
                onClicked: root.player.raise()
            }
        }

        Column {
            width: parent.width - cover.width - parent.spacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                width: parent.width
                text: root.player?.identity ?? ""
                elide: Text.ElideRight
                color: Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                font.bold: true
                font.capitalization: Font.AllUppercase
            }

            Text {
                width: parent.width
                text: root.player?.trackTitle ?? ""
                maximumLineCount: 2
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 2
                font.bold: true
            }

            Text {
                width: parent.width
                text: root.player?.trackArtist ?? ""
                elide: Text.ElideRight
                color: Theme.mauve
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            Text {
                width: parent.width
                visible: text !== ""
                text: root.player?.trackAlbum ?? ""
                elide: Text.ElideRight
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
            }
        }
    }

    // Progress bar; click to seek when the player supports it.
    Column {
        width: parent.width
        spacing: 4
        visible: root.player?.lengthSupported ?? false

        Rectangle {
            id: track

            width: parent.width
            height: 6
            radius: 3
            color: Theme.surface0

            Rectangle {
                width: root.player && root.player.length > 0
                    ? parent.width * Math.min(1, root.player.position / root.player.length)
                    : 0
                height: parent.height
                radius: parent.radius
                color: Theme.mauve
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                enabled: root.player?.canSeek ?? false
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => root.player.position = root.player.length * Math.max(0, Math.min(1, (mouse.x - 6) / track.width))
            }
        }

        Item {
            width: parent.width
            height: elapsed.implicitHeight

            Text {
                id: elapsed

                text: root.time(root.player?.position ?? 0)
                color: Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
            }

            Text {
                anchors.right: parent.right
                text: root.time(root.player?.length ?? 0)
                color: Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 18

        Repeater {
            model: [
                { icon: "󰒮", action: "previous", enabled: root.player?.canGoPrevious ?? false },
                { icon: root.player?.isPlaying ? "󰏤" : "󰐊", action: "toggle", enabled: root.player?.canTogglePlaying ?? false },
                { icon: "󰒭", action: "next", enabled: root.player?.canGoNext ?? false }
            ]

            Rectangle {
                id: button

                required property var modelData
                readonly property bool primary: modelData.action === "toggle"

                width: primary ? 44 : 36
                height: width
                radius: width / 2
                anchors.verticalCenter: parent.verticalCenter
                color: primary ? Theme.mauve : (mouse.containsMouse ? Theme.surface1 : Theme.surface0)
                opacity: modelData.enabled ? 1 : 0.4

                Text {
                    anchors.centerIn: parent
                    text: button.modelData.icon
                    color: button.primary ? Theme.base : Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: button.primary ? 20 : 16
                }

                MouseArea {
                    id: mouse

                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: button.modelData.enabled
                    onClicked: {
                        if (button.modelData.action === "previous")
                            root.player.previous();
                        else if (button.modelData.action === "next")
                            root.player.next();
                        else
                            root.player.togglePlaying();
                    }
                }
            }
        }
    }

    // MPRIS only reports the position on seeks; poll it while playing.
    Timer {
        interval: 1000
        repeat: true
        running: root.visible && (root.player?.isPlaying ?? false)
        onTriggered: root.player.positionChanged()
    }
}
