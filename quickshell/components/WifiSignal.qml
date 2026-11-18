import QtQuick

import qs

Item {
    id: root

    property real strength: 0
    property string visualState: Config.states.defaultState
    property string theme: Config.themes.dark
    property bool hovered: false
    property bool marked: false

    readonly property var palette: Config.statePalette(
        root.visualState,
        root.theme,
        root.hovered,
        false
    )
    readonly property int filledBars: Math.ceil(Math.max(0, Math.min(1, strength)) * 4)
    readonly property bool showDisabledMark: root.marked || root.palette.disabledMark

    implicitWidth: 20
    implicitHeight: 18

    Row {
        anchors.centerIn: parent
        width: 18
        height: parent.height
        spacing: 2

        Repeater {
            model: 4

            Item {
                required property int index

                width: 3
                height: root.height

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 5 + index * 3
                    color: index < root.filledBars
                        ? root.palette.foreground
                        : root.palette.secondary
                }
            }
        }
    }

    Rectangle {
        visible: root.showDisabledMark
        anchors.centerIn: parent
        width: 22
        height: 2
        rotation: -45
        color: root.palette.foreground
        radius: 1
    }
}
