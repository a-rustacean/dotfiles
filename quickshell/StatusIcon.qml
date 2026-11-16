import QtQuick

import "config.js" as Config

Item {
    id: root

    property string icon: ""
    property color color: Config.colors.text
    property int pixelSize: Config.quickSettings.iconFontSize
    property bool marked: false

    implicitWidth: pixelSize + 6
    implicitHeight: pixelSize + 6

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.color
        font.family: Config.ui.fontFamily
        font.pixelSize: root.pixelSize
    }

    Rectangle {
        visible: root.marked
        anchors.centerIn: parent
        width: root.pixelSize * 1.25
        height: 2
        rotation: -45
        color: root.color
        radius: 1
    }
}
