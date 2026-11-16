import Quickshell
import QtQuick

import "config.js" as Config

Rectangle {
    id: root

    implicitWidth: 100
    implicitHeight: Config.bar.height - Config.bar.margin

    property color backgroundColor: Config.bar.background
    property color disabledBackgroundColor: Config.bar.disabledBackground
    property color normalBorderColor: Config.colors.surface1
    property color hoverBorderColor: Config.colors.text
    property int borderSize: Config.ui.borderWidth
    property int cornerRadius: Config.ui.rounding
    property bool active: false
    property bool disabled: false

    readonly property Region blurRegion: Region {
        item: root
        radius: root.cornerRadius
    }

    color: disabled ? disabledBackgroundColor : backgroundColor
    border.width: borderSize
    border.color: (active || hover.hovered)
    ? hoverBorderColor
    : normalBorderColor

    radius: cornerRadius

    HoverHandler {
        id: hover
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Config.ui.animationDuration
            easing.type: Easing.OutQuint
        }
    }
}
