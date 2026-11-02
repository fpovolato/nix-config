// Connection of the active network device and live throughput of the
// default-route interface. Click to show connection details and traffic by
// process (NetworkPanel.qml).
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Item {
    id: root

    required property QsWindow window

    // Connected device, preferring Ethernet over Wi-Fi.
    readonly property NetworkDevice device: {
        const connected = Networking.devices.values.filter(d => d.connected && d.type !== DeviceType.None);
        return connected.find(d => d.type === DeviceType.Wired) ?? connected[0] ?? null;
    }
    readonly property bool limited: Networking.connectivity === NetworkConnectivity.Limited
        || Networking.connectivity === NetworkConnectivity.Portal

    property string download: "--"
    property string upload: "--"

    function icon() {
        if (!device)
            return "󰤮";
        if (device.type === DeviceType.Wired)
            return "󰈀";
        const network = device.networks.values.find(n => n.connected);
        const strength = network?.signalStrength ?? 0;
        return strength > 0.75 ? "󰤨" : strength > 0.5 ? "󰤥" : strength > 0.25 ? "󰤢" : "󰤟";
    }

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row

        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon()
            color: !root.device ? Theme.red : (root.limited ? Theme.peach : Theme.text)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 2
        }

        Text {
            visible: !root.device
            anchors.verticalCenter: parent.verticalCenter
            text: "offline"
            color: Theme.red
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        // Upload above download in a fixed-width column, so the bar does not
        // shift as the rates change.
        Column {
            visible: root.device !== null
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: [["↑", root.upload], ["↓", root.download]]

                Text {
                    required property var modelData

                    width: 76
                    text: modelData[0] + modelData[1].padStart(10, " ")
                    color: Theme.subtext
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                    lineHeight: 0.9
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: panel.toggle()
    }

    NetworkPanel {
        id: panel

        target: root
        barWindow: root.window
        device: root.device
    }

    // network-throughput samples the interface counters for 0.75 s and
    // prints "↓ <rate>  ↑ <rate>".
    Process {
        id: throughput

        command: [Scripts.networkThroughput]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const match = text.trim().match(/^↓\s+(.+?)\s+↑\s+(.+)$/);
                root.download = match ? match[1] : "--";
                root.upload = match ? match[2] : "--";
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!throughput.running)
                throughput.running = true;
        }
    }
}
