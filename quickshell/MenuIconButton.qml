import QtQuick
import QtQuick.Controls

import "config.js" as Config

Button {
    id: root

    property string glyph: ""
    property string actionName: ""
    property bool marked: false
    property bool selected: false
    property bool onSelectedSurface: false
    property bool borderless: false

    readonly property color restingBackground: root.selected
        ? Config.ui.selectedBackground
        : root.onSelectedSurface
            ? Config.colors.subtext1
            : Config.colors.surface1
    readonly property color hoveredBackground: root.selected
        ? Config.ui.selectedSecondary
        : root.onSelectedSurface
            ? Config.colors.subtext0
            : Config.colors.surface2
    readonly property color pressedBackground: root.selected
        ? Config.colors.surface1
        : root.onSelectedSurface
            ? Config.colors.overlay2
            : Config.colors.surface0

    implicitWidth: Config.quickSettings.buttonHeight
    implicitHeight: Config.quickSettings.buttonHeight
    padding: 0
    opacity: root.enabled && !root.marked ? 1 : 0.6

    Accessible.name: root.actionName

    contentItem: StatusIcon {
        icon: root.glyph
        marked: root.marked
        color: root.selected
            ? root.hovered || root.down
                ? Config.colors.text
                : Config.ui.selectedForeground
            : root.onSelectedSurface
                ? Config.ui.selectedForeground
                : Config.colors.text
        pixelSize: Config.quickSettings.iconFontSize
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Config.ui.animationDuration
            easing.type: Easing.OutQuint
        }
    }

    background: ThemedRectangle {
        backgroundColor: !root.enabled
            ? Config.bar.background
            : root.down
                ? root.pressedBackground
                : root.hovered
                    ? root.hoveredBackground
                    : root.restingBackground
        borderSize: root.borderless ? 0 : Config.ui.borderWidth
        borderColor: root.selected || root.onSelectedSurface
            ? Config.ui.selectedBackground
            : root.borderless ? "transparent" : Config.colors.surface1
        blurRegionEnabled: false

        Behavior on backgroundColor {
            ColorAnimation {
                duration: Config.ui.animationDuration
                easing.type: Easing.OutQuint
            }
        }
    }

    HoverHandler {
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
