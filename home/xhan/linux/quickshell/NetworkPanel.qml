// Network dropdown: connection details and traffic by process. The process
// list and its merging rules are adapted from the panel of
// egoist/omarchy-network-throughput (MIT): processes keep their row when
// they go idle, new activity enters on top, and traffic that ss cannot assign
// to a process is shown as "Other traffic".
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

BarPopup {
    id: root

    property NetworkDevice device
    readonly property Network network: device?.networks.values.find(n => n.connected) ?? null
    readonly property int processCount: 6

    property var rows: []
    property bool measured: false

    contentWidth: 440

    function formatRate(bytesPerSecond) {
        const value = Math.max(0, Number(bytesPerSecond) || 0);
        if (value < 1024)
            return Math.round(value) + " B/s";
        if (value < 1024 ** 2)
            return (value / 1024).toFixed(value < 10 * 1024 ? 1 : 0) + " KB/s";
        if (value < 1024 ** 3)
            return (value / 1024 ** 2).toFixed(value < 10 * 1024 ** 2 ? 1 : 0) + " MB/s";
        return (value / 1024 ** 3).toFixed(1) + " GB/s";
    }

    function details() {
        if (!device)
            return "Not connected";
        const parts = [device.name];
        if (device.type === DeviceType.Wired && device.linkSpeed > 0)
            parts.push(device.linkSpeed >= 1000 ? device.linkSpeed / 1000 + " Gb/s" : device.linkSpeed + " Mb/s");
        if (device.type === DeviceType.Wifi && network)
            parts.push(Math.round(network.signalStrength * 100) + "% signal");
        if (Networking.connectivity === NetworkConnectivity.Limited)
            parts.push("limited");
        else if (Networking.connectivity === NetworkConnectivity.Portal)
            parts.push("captive portal");
        return parts.join("  ·  ");
    }

    function key(row) {
        const name = String(row.name).toLowerCase().replace(/[^a-z0-9]/g, "");
        return name !== "" ? name : "pid:" + row.pid;
    }

    function isOther(row) {
        return Number(row.pid) <= 0 || row.name === "Other traffic";
    }

    function idle(row) {
        return { pid: row.pid, name: row.name, downloadBytesPerSecond: 0, uploadBytesPerSecond: 0 };
    }

    function merge(next) {
        const incoming = {};
        const incomingOrder = [];
        let other = null;
        for (const row of next) {
            if (isOther(row)) {
                other = row;
                continue;
            }
            const k = key(row);
            if (!(k in incoming)) {
                incoming[k] = idle(row);
                incomingOrder.push(k);
            }
            incoming[k].pid = row.pid;
            incoming[k].downloadBytesPerSecond += Number(row.downloadBytesPerSecond);
            incoming[k].uploadBytesPerSecond += Number(row.uploadBytesPerSecond);
        }

        const previous = {};
        const previousOrder = [];
        let previousOther = null;
        for (const row of rows) {
            if (isOther(row)) {
                previousOther = row;
                continue;
            }
            previous[key(row)] = row;
            previousOrder.push(key(row));
        }

        const selected = [];
        const taken = {};
        function add(k, row) {
            if (k in taken || selected.length >= processCount)
                return;
            taken[k] = true;
            selected.push(row);
        }

        const rate = row => row.downloadBytesPerSecond + row.uploadBytesPerSecond;
        for (const k of incomingOrder)
            if (!(k in previous) && rate(incoming[k]) > 0)
                add(k, incoming[k]);
        for (const k of previousOrder)
            add(k, incoming[k] ?? idle(previous[k]));
        for (const k of incomingOrder)
            add(k, incoming[k]);

        const otherRow = other ?? (previousOther ? idle(previousOther) : null);
        if (otherRow)
            selected.push(otherRow);
        return selected;
    }

    // Desktop entry icon for a process name, falling back to a generic one.
    function iconFor(name) {
        if (name === "Other traffic")
            return Quickshell.iconPath("network-transmit-receive", true);
        const needle = name.toLowerCase().replace(/[^a-z0-9]/g, "");
        const entry = DesktopEntries.applications.values.find(e => {
            const id = e.id.toLowerCase().replace(/[^a-z0-9]/g, "").replace(/desktop$/, "");
            return id === needle || e.name.toLowerCase().replace(/[^a-z0-9]/g, "") === needle;
        });
        return Quickshell.iconPath(entry?.icon ?? name, true) || Quickshell.iconPath("application-x-executable", true);
    }

    // Header: connection name and details.
    Column {
        width: parent.width
        spacing: 2

        Text {
            text: !root.device ? "Offline" : (root.device.type === DeviceType.Wifi ? root.network?.name ?? "Wi-Fi" : "Ethernet")
            color: Theme.mauve
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 2
            font.bold: true
        }

        Text {
            text: root.details()
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.surface0
    }

    Row {
        width: parent.width

        Text {
            width: parent.width - 2 * 96
            text: "PROCESS"
            color: Theme.overlay0
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 2
            font.bold: true
        }

        Repeater {
            model: ["↓ DOWN", "↑ UP"]

            Text {
                required property string modelData

                width: 96
                text: modelData
                horizontalAlignment: Text.AlignRight
                color: Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                font.bold: true
            }
        }
    }

    // Fixed height (one row per process plus "Other traffic") so the popup
    // keeps its size as rows come and go.
    Item {
        width: parent.width
        height: 26 * (root.processCount + 1)

        Column {
            id: processList

            width: parent.width

            Text {
                visible: root.rows.length === 0
                width: parent.width
                height: 26 * (root.processCount + 1)
                text: root.measured ? "No active network traffic" : "Measuring network traffic…"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            Repeater {
                model: root.rows

                Row {
                    id: processRow

                    required property var modelData

                    width: parent.width
                    height: 26

                    Image {
                        width: 18
                        height: 18
                        anchors.verticalCenter: parent.verticalCenter
                        sourceSize: Qt.size(36, 36)
                        source: root.iconFor(processRow.modelData.name)
                        asynchronous: true
                    }

                    Text {
                        width: parent.width - 18 - 2 * 96
                        leftPadding: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: processRow.modelData.name
                        elide: Text.ElideRight
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    Repeater {
                        model: [processRow.modelData.downloadBytesPerSecond, processRow.modelData.uploadBytesPerSecond]

                        Text {
                            required property real modelData

                            width: 96
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.formatRate(modelData)
                            horizontalAlignment: Text.AlignRight
                            color: modelData > 0 ? Theme.text : Theme.overlay0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: modelData > 0
                        }
                    }
                }
            }
        }
    }

    // process-throughput samples ss TCP counters for 0.75 s and prints a JSON
    // array of { pid, name, downloadBytesPerSecond, uploadBytesPerSecond }.
    Process {
        id: processes

        command: [Scripts.processThroughput]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text || "[]");
                    root.rows = root.merge(Array.isArray(parsed) ? parsed : []);
                } catch (error) {
                    console.warn("process-throughput:", error);
                }
                root.measured = true;
            }
        }
    }

    Timer {
        interval: 1500
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!processes.running)
                processes.running = true;
        }
    }
}
