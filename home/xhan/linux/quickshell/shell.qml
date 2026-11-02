// Quickshell entry point: one bar per connected screen.
// See https://quickshell.org/docs/
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }
}
