import QtQuick
import QtQuick.Controls
import PlayerBackend 1.0

ApplicationWindow {
    id: root
    width: 520
    height: 360
    visible: true
    title: qsTr("MPD Player")
    color: "#1e1e2e"

    MpdController {
        id: mpd
    }

    Column {
        anchors.centerIn: parent
        spacing: 16
        width: parent.width - 60

        // Song Information
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: mpd.currentSong.title !== "" ? mpd.currentSong.title : "No Track Loaded"
                color: "#cdd6f4"
                font.pixelSize: 22
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: mpd.currentSong.artist !== "" ? (mpd.currentSong.artist + " — " + mpd.currentSong.album) : ""
                color: "#a6adc8"
                font.pixelSize: 15
                elide: Text.ElideRight
            }
        }

        // Controls
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 14

            Button {
                text: "⏮"
                enabled: mpd.isConnected
                onClicked: mpd.previous()
            }

            Button {
                text: mpd.playbackState === MpdTypes.Playing ? "⏸ " : "▶"
                enabled: mpd.isConnected
                onClicked: mpd.togglePlayPause()
            }

            Button {
                text: "⏭"
                enabled: mpd.isConnected
                onClicked: mpd.next()
            }
        }
    }
}
