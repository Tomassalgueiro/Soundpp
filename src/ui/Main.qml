import QtQuick
import QtQuick.Controls.Basic
import PlayerBackend 1.0

ApplicationWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 640
    minimumHeight: 480
    visible: true
    title: qsTr("MPD Music Browser")
    color: theme.background

    Theme { id: theme }

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
                    height: 34
                    spacing: 10

                    Rectangle {
                        width: 34; height: 34; radius: 4
                        color: upHover.containsMouse ? theme.panelRaised : "transparent"
                        border.color: theme.hairline
                        border.width: 1
                        opacity: mpd.currentPath !== "" ? 1.0 : 0.4

                        Icons {
                            anchors.centerIn: parent
                            name: "chevronUp"
                            color: theme.textPrimary
                        }

                        MouseArea {
                            id: upHover
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: mpd.currentPath !== ""
                            onClicked: mpd.goUp()
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: mpd.currentPath === "" ? "/ (Music Root)" : "/" + mpd.currentPath
                        color: theme.textSecondary
                        font.family: theme.fontMono
                        font.pixelSize: 12
                        elide: Text.ElideLeft
                        width: parent.width - 44
                    }
                }

                Row {
                    width: parent.width
                    height: 34
                    spacing: 10

                    ComboBox {
                        id: modeSelector
                        height: 34
                        padding: 0
                        model: ["In-Order", "Shuffle Current", "Shuffle Selected Folders"]
                        currentIndex: mpd.queueMode
                        onActivated: function(index) {
                            mpd.queueMode = index
                        }

                        background: Rectangle {
                            implicitWidth: 190
                            radius: 4
                            color: theme.panel
                            border.color: theme.hairline
                            border.width: 1
                        }

                        contentItem: Text {
                            leftPadding: 12
                            rightPadding: 28
                            text: modeSelector.displayText
                            color: theme.textPrimary
                            font.family: theme.fontDisplay
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        indicator: Icons {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            name: "chevronDown"
                            color: theme.textSecondary
                        }

                        popup: Popup {
                            y: modeSelector.height + 2
                            width: modeSelector.width
                            implicitHeight: contentItem.implicitHeight + 2
                            padding: 1

                            background: Rectangle {
                                color: theme.panel
                                border.color: theme.hairline
                                border.width: 1
                                radius: 4
                            }

                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: modeSelector.popup.visible ? modeSelector.delegateModel : null
                                currentIndex: modeSelector.highlightedIndex
                                ScrollIndicator.vertical: ScrollIndicator {}
                            }
                        }

                        delegate: ItemDelegate {
                            width: modeSelector.width
                            padding: 0
                            highlighted: modeSelector.highlightedIndex === index

                            contentItem: Text {
                                leftPadding: 12
                                text: modelData
                                color: theme.textPrimary
                                font.family: theme.fontDisplay
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.highlighted ? theme.panelRaised : "transparent"
                            }
                        }
                    }

                    Button {
                        text: "Play selected (" + mpd.selectedFolders.length + ")"
                        visible: mpd.queueMode === MpdController.ModeShuffleSelectedFolders
                        enabled: mpd.selectedFolders.length > 0
                        padding: 0
                        onClicked: mpd.playCustomQueue()

                        background: Rectangle {
                            implicitHeight: 34
                            radius: 4
                            color: parent.hovered ? theme.panelRaised : "transparent"
                            border.color: theme.hairline
                            border.width: 1
                            opacity: parent.enabled ? 1.0 : 0.4
                        }

                        contentItem: Text {
                            leftPadding: 12
                            rightPadding: 12
                            text: parent.text
                            color: theme.textPrimary
                            font.family: theme.fontDisplay
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Clear"
                        visible: mpd.queueMode === MpdController.ModeShuffleSelectedFolders && mpd.selectedFolders.length > 0
                        padding: 0
                        onClicked: mpd.clearSelectedFolders()

                        background: Rectangle {
                            implicitHeight: 34
                            radius: 4
                            color: parent.hovered ? theme.panelRaised : "transparent"
                            border.color: theme.hairline
                            border.width: 1
                        }

                        contentItem: Text {
                            leftPadding: 12
                            rightPadding: 12
                            text: parent.text
                            color: theme.textSecondary
                            font.family: theme.fontDisplay
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                ListView {
                    id: fileList
                    width: parent.width
                    height: parent.height - 84
                    clip: true
                    model: mpd.currentFiles

                    delegate: ItemDelegate {
                        id: rowDelegate
                        width: fileList.width
                        height: 44
                        padding: 0
                        hoverEnabled: true

                        readonly property bool isFolder: modelData.isDirectory
                        readonly property bool selectable: isFolder && mpd.queueMode === MpdController.ModeShuffleSelectedFolders
                        readonly property bool isSelected: isFolder && mpd.isFolderSelected(modelData.path)

                        contentItem: Row {
                            leftPadding: 16
                            rightPadding: 8
                            spacing: 12

                            Rectangle {
                                width: 18; height: 18; radius: 3
                                anchors.verticalCenter: parent.verticalCenter
                                visible: rowDelegate.selectable
                                color: "transparent"
                                border.color: theme.hairline
                                border.width: 1

                                Icons {
                                    anchors.centerIn: parent
                                    name: "check"
                                    color: theme.accent
                                    weight: 1.6
                                    visible: rowDelegate.isSelected
                                }
                            }

                            Icons {
                                anchors.verticalCenter: parent.verticalCenter
                                name: rowDelegate.isFolder ? "folder" : "track"
                                color: rowDelegate.isFolder ? theme.accent : theme.textFaint
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.name
                                color: theme.textPrimary
                                font.family: theme.fontDisplay
                                font.pixelSize: 13
                                font.weight: rowDelegate.isFolder ? Font.DemiBold : Font.Normal
                                elide: Text.ElideRight
                                width: fileList.width - (rowDelegate.selectable ? 82 : 52)
                            }
                        }

                        background: Rectangle {
                            color: parent.hovered ? theme.panelRaised : "transparent"

                            Rectangle {
                                anchors.left: parent.left
                                width: 2
                                height: parent.height
                                color: rowDelegate.isSelected ? theme.accent : "transparent"
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 1
                                color: theme.hairline
                            }
                        }

                        onClicked: {
                            if (isFolder) {
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
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle { implicitWidth: 4; radius: 2; color: theme.hairline }
                        background: Item {}
                    }
                }
            }

            // Right side: Album cover, metadata, and Up Next
            Rectangle {
                width: (parent.width - parent.spacing) * 0.30
                height: parent.height
                color: theme.panel

                Rectangle { anchors.left: parent.left; width: 1; height: parent.height; color: theme.hairline }

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(parent.width, 170)
                        height: width
                        radius: 4
                        color: theme.panelRaised
                        border.color: theme.hairline
                        border.width: 1
                        clip: true

                        Image {
                            id: albumCover
                            anchors.fill: parent
                            anchors.margins: 1
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
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: mpd.currentSong.album || "No Album"
                        color: theme.textSecondary
                        font.family: theme.fontDisplay
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    Rectangle { width: parent.width; height: 1; color: theme.hairline }

                    Text {
                        text: "Up next"
                        color: theme.textFaint
                        font.family: theme.fontMono
                        font.pixelSize: 11
                        font.capitalization: Font.AllUppercase
                    }

                    ListView {
                        id: upNextList
                        width: parent.width
                        height: parent.height - y - 8
                        clip: true
                        model: mpd.upNextSongs

                        delegate: Item {
                            width: upNextList.width
                            height: 38

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                spacing: 10

                                Text {
                                    width: 16
                                    text: (index + 1).toString()
                                    color: theme.textFaint
                                    font.family: theme.fontMono
                                    font.pixelSize: 11
                                }

                                Column {
                                    width: parent.width - 26
                                    spacing: 1

                                    Text {
                                        width: parent.width
                                        text: modelData.title
                                        color: theme.textSecondary
                                        font.family: theme.fontDisplay
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        text: modelData.artist
                                        color: theme.textFaint
                                        font.family: theme.fontDisplay
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: upNextList.count === 0
                            text: "Queue ended"
                            color: theme.textFaint
                            font.family: theme.fontDisplay
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: theme.hairline
        }

        // Bottom: Player Controls
        Column {
            id: playerControlsPanel
            width: parent.width
            spacing: 10

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                spacing: 2

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: mpd.currentSong.title !== "" ? mpd.currentSong.title : "No Track Selected"
                    color: theme.textPrimary
                    font.family: theme.fontDisplay
                    font.pixelSize: 17
                    font.weight: Font.DemiBold
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
                    color: theme.textSecondary
                    font.family: theme.fontDisplay
                    font.pixelSize: 13
                }
            }

            TrackSlider {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 40
                theme: theme
                duration: mpd.currentSong.duration
                elapsedTime: mpd.elapsedTime
                isConnected: mpd.isConnected
                onSeekRequested: function(seconds) {
                    mpd.seek(seconds)
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 18

                Rectangle {
                    width: 32; height: 32; radius: 4
                    color: prevHover.containsMouse ? theme.panelRaised : "transparent"
                    opacity: mpd.isConnected ? 1.0 : 0.4

                    Icons { anchors.centerIn: parent; name: "prev"; color: theme.textPrimary }

                    MouseArea {
                        id: prevHover
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: mpd.isConnected
                        onClicked: mpd.previous()
                    }
                }

                Rectangle {
                    width: 44; height: 44; radius: 6
                    color: theme.accent
                    opacity: mpd.isConnected ? 1.0 : 0.4

                    Icons {
                        anchors.centerIn: parent
                        name: mpd.playbackState === MpdController.Playing ? "pause" : "play"
                        color: theme.accentInk
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: mpd.isConnected
                        onClicked: mpd.togglePlayPause()
                    }
                }

                Rectangle {
                    width: 32; height: 32; radius: 4
                    color: nextHover.containsMouse ? theme.panelRaised : "transparent"
                    opacity: mpd.isConnected ? 1.0 : 0.4

                    Icons { anchors.centerIn: parent; name: "next"; color: theme.textPrimary }

                    MouseArea {
                        id: nextHover
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: mpd.isConnected
                        onClicked: mpd.next()
                    }
                }
            }
        }
    }
}
