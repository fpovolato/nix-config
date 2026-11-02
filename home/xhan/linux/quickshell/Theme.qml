// Catppuccin Mocha colors and shared sizes for the bar.
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color overlay0: "#6c7086"
    readonly property color text: "#cdd6f4"
    readonly property color subtext: "#a6adc8"
    readonly property color mauve: "#cba6f7"
    readonly property color blue: "#89b4fa"
    readonly property color red: "#f38ba8"
    readonly property color peach: "#fab387"

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int barHeight: 34
    readonly property int radius: 10
    readonly property int spacing: 8
}
