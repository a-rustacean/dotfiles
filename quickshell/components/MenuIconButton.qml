import QtQuick
import QtQuick.Controls

import qs

Button {
    id: root

    property string glyph: ""
    property string actionName: ""
    property bool marked: false
    property bool borderless: false
    property string visualState: Config.states.defaultState
    property string theme: Config.themes.dark

    readonly property string effectiveVisualState: !root.enabled || root.marked
        ? Config.states.disabled
        : root.visualState
    readonly property var palette: Config.statePalette(
        root.effectiveVisualState,
        root.theme,
        root.hovered,
        root.down
    )

    implicitWidth: Config.quickSettings.buttonHeight
    implicitHeight: Config.quickSettings.buttonHeight
    padding: 0

    Accessible.name: root.actionName

    contentItem: StatusIcon {
        icon: root.glyph
        marked: root.marked
        visualState: root.effectiveVisualState
        theme: root.theme
        color: root.palette.foreground
        pixelSize: Config.quickSettings.iconFontSize
    }

    background: ThemedRectangle {
        visualState: root.effectiveVisualState
        theme: root.theme
        hovered: root.hovered
        pressed: root.down
        borderless: root.borderless
        borderColor: root.borderless ? "transparent" : Config.colors.surface1
        blurRegionEnabled: false
    }

    HoverHandler {
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
