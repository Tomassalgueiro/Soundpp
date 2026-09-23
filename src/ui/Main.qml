import QtQuick
import QtQuick.Controls
import PlayerBackend 1.0

ApplicationWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 640
    minimumHeight: 480
    visible: true
    title: qsTr("MPD Music Browser")
    color: "#1e1e2e"

    MpdController {
        id: mpd
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

	Row {
            width: parent.width
            height: parent.height - playerControlsPanel.height - parent.spacing - 32
            spacing: 16

            Column {
                width: (parent.width - parent.spacing) * 0.70
                height: parent.height
                spacing: 8

                Row {
                    width: parent.width
                    spacing: 8

                    Button {
                        text: "↑ Up"
                        enabled: mpd.currentPath !== ""
                        onClicked: mpd.goUp()
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: mpd.currentPath === "" ? "/ (Music Root)" : "/" + mpd.currentPath
                        color: "#a6adc8"
                        font.pixelSize: 13
                        elide: Text.ElideLeft
                        width: parent.width - 80
                    }
                }

                ListView {
                    id: fileList
                    width: parent.width
                    height: parent.height - 40
                    clip: true
                    model: mpd.currentFiles

                    delegate: ItemDelegate {
                        width: fileList.width
                        height: 38

                        contentItem: Row {
                            spacing: 10
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: modelData.isDirectory ? "📁" : "🎵"
                                font.pixelSize: 15
                            }

                            Text {
                                text: modelData.name
                                color: modelData.isDirectory ? "#89b4fa" : "#cdd6f4"
                                font.pixelSize: 13
                                font.bold: modelData.isDirectory
                                elide: Text.ElideRight
                                width: fileList.width - 50
                            }
                        }

                        background: Rectangle {
                            color: parent.hovered ? "#313244" : "transparent"
                            radius: 4
                        }

                        onClicked: {
                            if (modelData.isDirectory) {
                                mpd.openFolder(modelData.path)
                            } else {
                                mpd.playItem(modelData.path)
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }
                }
            }

            Rectangle {
                width: (parent.width - parent.spacing) * 0.30
                height: parent.height
                color: "#181825"
                radius: 8
                clip: true

                Column {
                    anchors.centerIn: parent
                    spacing: 12
                    width: parent.width - 24

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(parent.width, 220)
                        height: width
                        radius: 8
                        color: "#313244"
                        clip: true

                        Image {
                            id: albumCover
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true

			    source: mpd.currentSong.uri !== "" 
				? mpd.coverArtUrl
				: "ui/assets/default.png"

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    source = "ui/assets/default_album.png"
                                }
                            }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: mpd.currentSong.album || "No Album"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.italic: true
                        elide: Text.ElideRight
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#313244"
        }

        Column {
            id: playerControlsPanel
            width: parent.width
            spacing: 8

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                spacing: 2

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: mpd.currentSong.title !== "" ? mpd.currentSong.title : "No Track Selected"
                    color: "#cdd6f4"
                    font.pixelSize: 18
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: mpd.currentSong.artist !== ""
		    text: {
			    var artist = mpd.currentSong.artist
			    var album = mpd.currentSong.album

			    var hasAlbum = album && album.trim() !== "" && album !== "Uknown Album"

			    return hasAlbum ? (artist + " on " + album) : artist
		    }
                    color: "#a6adc8"
                    font.pixelSize: 13
                }
            }

            TrackSlider {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 40
                duration: mpd.currentSong.duration
                elapsedTime: mpd.elapsedTime
                isConnected: mpd.isConnected
                onSeekRequested: function(seconds) {
                    mpd.seek(seconds)
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14

                Button {
                    text: "⏮"
                    enabled: mpd.isConnected
                    onClicked: mpd.previous()
                }

                Button {
                    text: mpd.playbackState === MpdController.Playing ? "⏸" : "▶"
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
}
