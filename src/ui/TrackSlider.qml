import QtQuick
import QtQuick.Controls.Basic

// Same public API as before (duration, elapsedTime, isConnected,
// seekRequested) — only the visuals changed: a thin hairline track with an
// accent fill and a small diamond handle instead of a default pill slider.
// Colours come from `theme` (see Theme.qml), passed in by whoever uses this.
Item {
    id: root

    property int duration: 0
    property int elapsedTime: 0
    property bool isConnected: false
    property QtObject theme

    signal seekRequested(int seconds)

    implicitHeight: layout.implicitHeight
    implicitWidth: 300

    function formatTime(totalSeconds) {
        var minutes = Math.floor(totalSeconds / 60)
        var seconds = totalSeconds % 60
        return minutes + ":" + (seconds < 10 ? "0" + seconds : seconds)
    }

    Column {
        id: layout
        anchors.fill: parent
        spacing: 6

        Slider {
            id: slider
            width: parent.width
            padding: 0
            from: 0
            to: Math.max(root.duration, 1)
            enabled: root.isConnected && root.duration > 0
            value: pressed ? value : root.elapsedTime

            onMoved: root.seekRequested(Math.round(value))

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 3
                color: root.theme.hairline

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    color: slider.enabled ? root.theme.accent : root.theme.hairline
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 8
                implicitHeight: 8
                rotation: 45
                color: slider.enabled ? root.theme.accent : root.theme.hairline
                visible: root.isConnected
            }
        }

        Item {
            width: parent.width
            height: elapsedLabel.implicitHeight

            Text {
                id: elapsedLabel
                anchors.left: parent.left
                text: root.formatTime(slider.pressed ? Math.round(slider.value) : root.elapsedTime)
                color: root.theme.textFaint
                font.family: root.theme.fontMono
                font.pixelSize: 11
            }

            Text {
                anchors.right: parent.right
                text: root.formatTime(root.duration)
                color: root.theme.textFaint
                font.family: root.theme.fontMono
                font.pixelSize: 11
            }
        }
    }
}
