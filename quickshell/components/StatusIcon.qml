import QtQuick

import "../config.js" as Config

Item {
    id: root

    property string icon: ""
    property string visualState: Config.states.default
    property string theme: Config.themes.dark
    property bool hovered: false
    property bool pressed: false
    property color color: root.palette.foreground
    property int pixelSize: Config.quickSettings.iconFontSize
    property bool marked: false

    readonly property var palette: Config.statePalette(
        root.visualState,
        root.theme,
        root.hovered,
        root.pressed
    )
    readonly property bool showDisabledMark: root.marked || root.palette.disabledMark

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
        visible: root.showDisabledMark
        anchors.centerIn: parent
        width: root.pixelSize * 1.25
        height: 2
        rotation: -45
        color: root.color
        radius: 1
    }
}
