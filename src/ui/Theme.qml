import QtQuick

QtObject {
    id: theme

    readonly property color background:    "#232537"  // bg0: window background
    readonly property color panel:         "#2b2e44"  // bg1: side panel / popups
    readonly property color panelRaised:   "#353954"  // bg2: hover fill, pressed state
    readonly property color hairline:      "#424769"  // bg4: subtle borders and divider lines
    readonly property color accent:        "#a87ffb"  // color1: signature accent
    readonly property color accentInk:     "#181926"  // bg_dim: dark content drawn on accent
    readonly property color textPrimary:   "#cfd6ea"  // fg: titles, primary labels
    readonly property color textSecondary: "#63b5f6"  // grey1 / muted aqua: secondary labels
    readonly property color textFaint:     "#6f7697"  // grey0: timestamps, counters, disabled text

    // Fonts
    // Falls back to the platform default sans/monospace if these aren't
    // installed. Install "Inter" and "JetBrainsMono Nerd Font" for the intended look.
    readonly property string fontDisplay: "Inter"
    readonly property string fontMono:    "JetBrainsMono Nerd Font"
}
