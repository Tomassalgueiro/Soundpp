import QtQuick
import QtQuick.Controls

Item {
    id: root

    property int duration: 0
    property int elapsedTime: 0
    property bool isConnected: false

    signal seekRequested(int seconds)

    implicitHeight: layout.implicitHeight
    implicitWidth: 300

    function formatTime(totalSeconds) {
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        return minutes + ":" + (seconds < 10 ? "0" + seconds : seconds);
    }

    Column {
        id: layout
        anchors.fill: parent
        spacing: 4

        Slider {
            id: slider
            width: parent.width
            from: 0
            to: Math.max(root.duration, 1)
            enabled: root.isConnected && root.duration > 0
            value: pressed ? value : root.elapsedTime

            onMoved: {
                root.seekRequested(Math.round(value))
            }
        }

        Row {
            width: parent.width

            Text {
                text: root.formatTime(slider.pressed ? Math.round(slider.value) : root.elapsedTime)
                color: "#a6adc8"
                font.pixelSize: 12
            }

            Item {
                width: parent.width - 80
                height: 1
            }

            Text {
                text: root.formatTime(root.duration)
                color: "#a6adc8"
                font.pixelSize: 12
            }
        }
    }
}
