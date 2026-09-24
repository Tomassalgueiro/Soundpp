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

            // Left side: Directory browser and queue mode selection
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

                Row {
                    width: parent.width
                    spacing: 8

                    ComboBox {
                        id: modeSelector
                        model: ["In-Order", "Shuffle Current", "Shuffle Selected Folders"]
                        currentIndex: mpd.queueMode
                        onActivated: function(index) {
                            mpd.queueMode = index
                        }
                    }

                    Button {
                        text: "Play Selected (" + mpd.selectedFolders.length + ")"
                        visible: mpd.queueMode === MpdController.ModeShuffleSelectedFolders
                        enabled: mpd.selectedFolders.length > 0
                        onClicked: mpd.playCustomQueue()
                    }

                    Button {
                        text: "Clear"
                        visible: mpd.queueMode === MpdController.ModeShuffleSelectedFolders && mpd.selectedFolders.length > 0
                        onClicked: mpd.clearSelectedFolders()
                    }
                }

                ListView {
                    id: fileList
                    width: parent.width
                    height: parent.height - 85
                    clip: true
                    model: mpd.currentFiles

                    delegate: ItemDelegate {
                        width: fileList.width
                        height: 40

                        contentItem: Row {
                            spacing: 10
                            anchors.verticalCenter: parent.verticalCenter

                            CheckBox {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: modelData.isDirectory && mpd.queueMode === MpdController.ModeShuffleSelectedFolders
                                checked: mpd.isFolderSelected(modelData.path)
                                onToggled: mpd.toggleSelectFolder(modelData.path)
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.isDirectory ? "📁" : "🎵"
                                font.pixelSize: 15
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.name
                                color: modelData.isDirectory ? "#89b4fa" : "#cdd6f4"
                                font.pixelSize: 13
                                font.bold: modelData.isDirectory
                                elide: Text.ElideRight
                                width: fileList.width - 90
                            }
                        }

                        background: Rectangle {
                            color: parent.hovered ? "#313244" : "transparent"
                            radius: 4
                        }

                        onClicked: {
                            if (modelData.isDirectory) {
                                if (mpd.queueMode === MpdController.ModeShuffleSelectedFolders) {
                                    mpd.toggleSelectFolder(modelData.path)
                                } else {
                                    mpd.openFolder(modelData.path)
                                }
                            } else {
                                mpd.playFolderQueue(mpd.currentPath, modelData.path)
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }
                }
            }

            // Right side: Album cover, metadata, and Up Next
            Rectangle {
                width: (parent.width - parent.spacing) * 0.30
                height: parent.height
                color: "#181825"
                radius: 8
                clip: true

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(parent.width, 170)
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

                            readonly property string defaultCover: "assets/default_album.png"

                            source: (mpd.currentSong.uri !== "" && mpd.coverArtUrl !== "")
                                    ? mpd.coverArtUrl
                                    : defaultCover

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    source = defaultCover
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

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#313244"
                    }

                    Text {
                        text: "UP NEXT"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#89b4fa"
                    }

                    ListView {
                        id: upNextList
                        width: parent.width
                        height: parent.height - y - 8
                        clip: true
                        model: mpd.upNextSongs

                        delegate: Item {
                            width: upNextList.width
                            height: 36

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                spacing: 2

                                Text {
                                    text: (index + 1) + ". " + modelData.title
                                    color: "#cdd6f4"
                                    font.pixelSize: 12
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                                Text {
                                    text: modelData.artist
                                    color: "#6c7086"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: upNextList.count === 0
                            text: "Queue ended"
                            color: "#585b70"
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#313244"
        }

        // Bottom: Player Controls
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
