// Track of the current MPRIS player (Spotify, browsers, video players).
// Click to play or pause, scroll to skip, right click for the player card
// (MediaPanel.qml). Hidden when nothing is playing or paused.
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

Item {
    id: root

    required property QsWindow window

    // The playing player wins, then a paused one.
    readonly property MprisPlayer player: {
        const players = Mpris.players.values.filter(p => p.trackTitle !== "");
        return players.find(p => p.isPlaying)
            ?? players.find(p => p.playbackState === MprisPlaybackState.Paused)
            ?? null;
    }

    visible: player !== null
    onPlayerChanged: {
        if (!player)
            panel.visible = false;
    }

    implicitWidth: visible ? row.implicitWidth : 0
    implicitHeight: row.implicitHeight

    Row {
        id: row

        spacing: 8

        ClippingRectangle {
            width: 22
            height: 22
            radius: 6
            color: Theme.surface0
            anchors.verticalCenter: parent.verticalCenter
            visible: art.status === Image.Ready

            Image {
                id: art

                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                sourceSize: Qt.size(44, 44)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.player?.isPlaying ? "󰏤" : "󰐊"
            color: Theme.mauve
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 2
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 300)
            text: (root.player?.trackTitle ?? "") + (root.player?.trackArtist ? "  ·  " + root.player.trackArtist : "")
            elide: Text.ElideRight
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                panel.toggle();
            else if (root.player?.canTogglePlaying)
                root.player.togglePlaying();
        }

        onWheel: wheel => {
            if (wheel.angleDelta.y < 0 && root.player?.canGoNext)
                root.player.next();
            else if (wheel.angleDelta.y > 0 && root.player?.canGoPrevious)
                root.player.previous();
        }
    }

    MediaPanel {
        id: panel

        target: root
        barWindow: root.window
        player: root.player
    }
}
