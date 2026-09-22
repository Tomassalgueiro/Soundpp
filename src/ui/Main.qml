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
	width: parent.width - 60
        spacing: 20

	    Column {
		anchors.centerIn: parent
		width: parent.width - 60
		spacing: 20

		    Text {
			anchors.horizontalCenter: parent.horizontalCenter
			text: mpd.currentSong.title !== "" ? mpd.currentSong.title : "No Track"
			color: "#cdd6f4"
			font.pixelSize: 22
			font.bold: true
			elide: Text.ElideRight
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
		    }
		    Text {
			anchors.horizontalCenter: parent.horizontalCenter
			visible: mpd.currentSong.artist !== "" || mpd.currentSong.album !== ""
			text: {
			    var artist = mpd.currentSong.artist || "Unknown Artist"
			    var album = mpd.currentSong.album || "Unknown Album"
			    return artist + " on " + album
			}
			color: "#a6adc8"
			font.pixelSize: 15
			elide: Text.ElideRight
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
		    }


	    }

	    TrackSlider {
		    width: parent.width
		    duration: mpd.currentSong.duration
		    elapsedTime: mpd.elapsedTime
		    isConnected: mpd.isConnected

		    onSeekRequested: function(seconds){
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
                    text: mpd.playbackState === MpdController.Playing ? "⏸ " : "▶"
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
