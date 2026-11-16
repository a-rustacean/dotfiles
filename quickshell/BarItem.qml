import QtQuick

import "config.js" as Config

ThemedRectangle {
    id: root

    implicitWidth: 100
    implicitHeight: Config.bar.height - Config.bar.margin

    property color disabledBackgroundColor: Config.bar.disabledBackground
    property color normalBorderColor: Config.colors.surface1
    property color hoverBorderColor: Config.colors.text
    property bool active: false
    property bool selected: false
    property bool disabled: false

    backgroundColor: selected
        ? Config.ui.selectedBackground
        : disabled
            ? disabledBackgroundColor
            : Config.bar.background
    borderColor: selected
        ? Config.ui.selectedBackground
        : (active || hover.hovered)
            ? hoverBorderColor
            : normalBorderColor

    HoverHandler {
        id: hover
    }

    Behavior on borderColor {
        ColorAnimation {
            duration: Config.ui.animationDuration
            easing.type: Easing.OutQuint
        }
    }
}
