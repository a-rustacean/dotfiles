import QtQuick

import "config.js" as Config

Item {
    id: root

    property real strength: 0
    property bool selected: false
    property bool marked: false

    readonly property int filledBars: Math.ceil(Math.max(0, Math.min(1, strength)) * 4)

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
                        ? root.selected ? Config.ui.selectedForeground : Config.colors.text
                        : Config.colors.surface1
                }
            }
        }
    }

    Rectangle {
        visible: root.marked
        anchors.centerIn: parent
        width: 22
        height: 2
        rotation: -45
        color: root.selected ? Config.ui.selectedForeground : Config.colors.text
        radius: 1
    }
}
