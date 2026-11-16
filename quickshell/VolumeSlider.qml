import QtQuick
import QtQuick.Controls

import "config.js" as Config

Slider {
    id: root

    property var audio: null
    property bool selected: false

    from: 0
    to: 1
    value: audio ? audio.volume : 0
    enabled: audio !== null
    implicitWidth: Config.quickSettings.sliderWidth
    implicitHeight: 24

    onMoved: {
        if (audio)
            audio.volume = value;
    }

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: 4
        radius: height / 2
        color: root.selected ? Config.colors.overlay1 : Config.colors.surface1

        Rectangle {
            width: parent.width * root.visualPosition
            height: parent.height
            radius: parent.radius
            color: root.selected ? Config.ui.selectedForeground : Config.colors.text
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: 12
        height: 12
        radius: width / 2
        color: root.selected
            ? Config.ui.selectedForeground
            : root.enabled ? Config.colors.text : Config.colors.overlay1
        border.width: Config.ui.borderWidth
        border.color: Config.colors.surface1
    }
}
