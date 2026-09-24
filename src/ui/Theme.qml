import QtQuick

QtObject {
    id: theme

    readonly property color background:    "#2d353b"  // bg0: window background
    readonly property color panel:         "#343f44"  // bg1: side panel / popups
    readonly property color panelRaised:   "#3d484d"  // bg2: hover fill, pressed state
    readonly property color hairline:      "#475258"  // bg4: subtle borders and divider lines
    readonly property color accent:        "#a7c080"  // color1: signature accent
    readonly property color accentInk:     "#232a2e"  // bg_dim: dark content drawn on accent
    readonly property color textPrimary:   "#d3c6aa"  // fg: titles, primary labels
    readonly property color textSecondary: "#9da9a0"  // grey1 / muted aqua: secondary labels
    readonly property color textFaint:     "#7a8478"  // grey0: timestamps, counters, disabled text

    // Fonts
    // Falls back to the platform default sans/monospace if these aren't
    // installed. Install "Inter" and "JetBrains Mono" for the intended look.
    readonly property string fontDisplay: "Inter"
    readonly property string fontMono:    "JetBrainsMono Nerd Font"
}
