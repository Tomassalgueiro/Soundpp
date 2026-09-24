// =============================================================================
// Theme.qml — every colour and typeface the UI uses, in one place.
//
// Main.qml, TrackSlider.qml and Icons.qml never hardcode a colour or a font
// family — they all read it from an instance of this file. To make a new
// theme, copy this file, change the values below, and swap it in (or expose
// several Theme variants and let the app pick one at startup).
//
// Usage:
//   Theme { id: theme }
//   Rectangle { color: theme.background }
// =============================================================================

import QtQuick

QtObject {
    id: theme

    // ---- Palette ----------------------------------------------------------
    // Keep the accent to a single colour, used sparingly: the play button,
    // the active/selected row, and the seek handle. Everything else stays
    // neutral so the accent keeps its meaning.
    readonly property color background:    "#12151b"  // window background
    readonly property color panel:         "#181c24"  // side panel / popups
    readonly property color panelRaised:   "#1f242e"  // hover fill, pressed state
    readonly property color hairline:      "#2a2f3a"  // borders and divider lines
    readonly property color accent:        "#c99a4b"  // brass accent
    readonly property color accentInk:     "#141821"  // content drawn on top of `accent`
    readonly property color textPrimary:   "#eae7e1"  // titles, primary labels
    readonly property color textSecondary: "#9aa0ab"  // artist/album, secondary labels
    readonly property color textFaint:     "#5b6069"  // timestamps, counters, disabled text

    // ---- Typography ---------------------------------------------------------
    // Falls back to the platform default sans/monospace if these aren't
    // installed. Install "Inter" and "JetBrains Mono" for the intended look.
    readonly property string fontDisplay: "Inter"
    readonly property string fontMono:    "JetBrains Mono"
}
