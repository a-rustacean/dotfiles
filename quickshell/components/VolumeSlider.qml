import QtQuick
import QtQuick.Controls

import qs

Slider {
    id: root

    property var audio: null
    property string visualState: Config.states.defaultState
    property string theme: Config.themes.dark
    property bool pointerHovered: false
    property bool surfaceHovered: false
    readonly property bool stateHovered: root.pointerHovered || root.surfaceHovered
    readonly property var palette: Config.statePalette(
        root.visualState,
        root.theme,
        root.stateHovered,
        root.pressed
    )

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

    HoverHandler {
        onHoveredChanged: root.pointerHovered = hovered
    }

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: 4
        radius: height / 2
        color: root.theme === Config.themes.light
            ? Config.colors.subtext0
            : root.visualState === Config.states.active
                ? root.stateHovered ? Config.colors.surface1 : Config.colors.overlay1
                : Config.colors.surface1

        Rectangle {
            width: parent.width * root.visualPosition
            height: parent.height
            radius: parent.radius
            color: root.visualState === Config.states.disabled
                ? root.theme === Config.themes.light
                    ? Config.colors.surface0
                    : Config.colors.subtext0
                : root.theme === Config.themes.light
                    ? Config.colors.base
                    : root.visualState === Config.states.active
                        ? root.stateHovered ? Config.colors.text : Config.ui.activeForeground
                        : Config.colors.text
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: 12
        height: 12
        radius: width / 2
        color: root.visualState === Config.states.disabled
            ? root.theme === Config.themes.light
                ? Config.colors.surface0
                : Config.colors.subtext0
            : root.theme === Config.themes.light
                ? Config.colors.base
                : root.visualState === Config.states.active
                    ? root.stateHovered ? Config.colors.text : Config.ui.activeForeground
                    : Config.colors.text
        border.width: Config.ui.borderWidth
        border.color: root.visualState === Config.states.disabled
            ? root.theme === Config.themes.light
                ? Config.colors.surface1
                : Config.colors.subtext0
            : Config.colors.surface1
    }
}
