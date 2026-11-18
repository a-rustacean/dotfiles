import Quickshell
import QtQuick

import "../config.js" as Config

Rectangle {
    id: root

    property string visualState: Config.states.default
    property string theme: Config.themes.dark
    property var defaultBackgroundColor: null
    property color borderColor: Config.colors.surface1
    property color highlightBorderColor: Config.colors.text
    property int borderSize: Config.ui.borderWidth
    property int cornerRadius: Config.ui.rounding
    property bool hovered: false
    property bool pressed: false
    property bool trackHover: false
    property bool highlighted: false
    property bool borderless: false
    property bool blurRegionEnabled: true

    readonly property var palette: Config.statePalette(
        root.visualState,
        root.theme,
        root.hovered,
        root.pressed,
        root.defaultBackgroundColor
    )
    readonly property color resolvedBackgroundColor: root.palette.background
    readonly property color resolvedForegroundColor: root.palette.foreground
    readonly property color resolvedSecondaryColor: root.palette.secondary
    readonly property color resolvedTertiaryColor: root.palette.tertiary
    readonly property string resolvedTheme: root.palette.theme
    readonly property color resolvedBorderColor: root.visualState === Config.states.active
            && !root.hovered && !root.pressed
        ? Config.ui.activeBackground
        : root.highlighted || root.hovered || root.pressed
            ? root.highlightBorderColor
            : root.borderColor

    HoverHandler {
        enabled: root.trackHover
        onHoveredChanged: root.hovered = hovered
    }

    readonly property Region blurRegion: Region {
        item: root
        radius: root.cornerRadius
    }

    color: root.resolvedBackgroundColor
    border.width: root.borderless ? 0 : root.borderSize
    border.color: root.resolvedBorderColor
    radius: root.cornerRadius

    Behavior on color {
        ColorAnimation {
            duration: Config.ui.animationDuration
            easing.type: Easing.OutQuint
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Config.ui.animationDuration
            easing.type: Easing.OutQuint
        }
    }
}
