// Title of the focused window, shown on the monitor that has it.
import QtQuick
import Quickshell.Hyprland

Text {
    required property HyprlandMonitor monitor
    readonly property HyprlandToplevel toplevel: Hyprland.activeToplevel

    text: toplevel && toplevel.monitor === monitor ? toplevel.title : ""
    elide: Text.ElideRight
    color: Theme.subtext
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
}
