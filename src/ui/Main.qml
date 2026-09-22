import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("MPD Music Player")

    color: "#1e1e2e"

    Column {
        anchors.centerIn: parent
        spacing: 16

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("MPD Quick Player Ready")
            font.pixelSize: 20
            font.bold: true
            color: "#cdd6f4"
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Test Button")
            onClicked: {
                console.log("QML Button clicked!")
            }
        }
    }
}
