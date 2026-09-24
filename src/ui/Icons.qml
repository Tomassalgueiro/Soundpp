// =============================================================================
// Icons.qml — small monochrome vector icon set drawn on a Canvas.
//
// Every icon in the interface is one of the shapes below rather than a
// coloured emoji glyph, so icon colour always comes from Theme and always
// matches the current theme instead of the font's built-in emoji palette.
//
// Usage:
//   Icons { name: "play"; color: theme.accentInk }
// =============================================================================

import QtQuick

Canvas {
    id: icon

    property string name: "track"
    property color color: "#eae7e1"
    property real weight: 1.4
    property int size: 16

    width: size
    height: size

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.strokeStyle = icon.color
        ctx.fillStyle = icon.color
        ctx.lineWidth = icon.weight
        ctx.lineJoin = "round"
        ctx.lineCap = "round"

        switch (icon.name) {
        case "chevronUp":
            ctx.beginPath()
            ctx.moveTo(3, 10); ctx.lineTo(8, 4); ctx.lineTo(13, 10)
            ctx.stroke()
            break

        case "chevronDown":
            ctx.beginPath()
            ctx.moveTo(3, 6); ctx.lineTo(8, 12); ctx.lineTo(13, 6)
            ctx.stroke()
            break

        case "folder":
            ctx.beginPath()
            ctx.moveTo(1, 4); ctx.lineTo(6, 4); ctx.lineTo(7.5, 6); ctx.lineTo(15, 6)
            ctx.lineTo(15, 13); ctx.lineTo(1, 13)
            ctx.closePath()
            ctx.stroke()
            break

        case "track":
            ctx.beginPath()
            ctx.arc(5, 12, 2.4, 0, Math.PI * 2)
            ctx.fill()
            ctx.fillRect(6.8, 2, 1.3, 10)
            ctx.beginPath()
            ctx.moveTo(8.1, 2)
            ctx.quadraticCurveTo(14, 3, 8.1, 7)
            ctx.closePath()
            ctx.fill()
            break

        case "check":
            ctx.beginPath()
            ctx.moveTo(2, 8); ctx.lineTo(6, 12); ctx.lineTo(14, 3)
            ctx.stroke()
            break

        case "prev":
            ctx.fillRect(1, 1, 2, 14)
            ctx.beginPath()
            ctx.moveTo(15, 1); ctx.lineTo(15, 15); ctx.lineTo(4, 8)
            ctx.closePath(); ctx.fill()
            break

        case "play":
            ctx.beginPath()
            ctx.moveTo(2, 1); ctx.lineTo(2, 15); ctx.lineTo(15, 8)
            ctx.closePath(); ctx.fill()
            break

        case "pause":
            ctx.fillRect(2, 1, 4, 14)
            ctx.fillRect(10, 1, 4, 14)
            break

        case "next":
            ctx.fillRect(13, 1, 2, 14)
            ctx.beginPath()
            ctx.moveTo(1, 1); ctx.lineTo(1, 15); ctx.lineTo(12, 8)
            ctx.closePath(); ctx.fill()
            break
        }
    }

    onColorChanged: requestPaint()
    onNameChanged: requestPaint()
    onWeightChanged: requestPaint()
    Component.onCompleted: requestPaint()
}
