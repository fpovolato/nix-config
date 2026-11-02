// Volume of the default PipeWire output. Scroll to change it, click to mute,
// right click to open pwvucontrol.
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Text {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property int percent: Math.round((sink?.audio?.volume ?? 0) * 100)

    // Binds the sink so its audio properties are available.
    PwObjectTracker {
        objects: [root.sink]
    }

    text: muted ? "󰝟 muted" : (percent > 50 ? "󰕾" : percent > 0 ? "󰖀" : "󰕿") + " " + percent + "%"
    color: muted ? Theme.red : Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                Quickshell.execDetached(["pwvucontrol"]);
            else if (root.sink?.audio)
                root.sink.audio.muted = !root.sink.audio.muted;
        }

        onWheel: wheel => {
            if (!root.sink?.audio)
                return;
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + step));
        }
    }
}
