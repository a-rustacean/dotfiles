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

    implicitWidth: Config.quickSettings.buttonHeight
    implicitHeight: Config.quickSettings.buttonHeight
    padding: 0

    Accessible.name: root.actionName

    contentItem: StatusIcon {
        icon: root.glyph
        marked: root.marked
        color: root.selected || root.onSelectedSurface
            ? Config.ui.selectedForeground
            : root.enabled ? Config.colors.text : Config.colors.overlay1
        pixelSize: Config.quickSettings.iconFontSize
    }

    background: ThemedRectangle {
        backgroundColor: root.selected || root.onSelectedSurface
            ? Config.ui.selectedBackground
            : root.down
                ? Config.colors.surface1
                : root.hovered
                    ? Config.colors.surface0
                    : Config.bar.background
        borderSize: root.borderless ? 0 : Config.ui.borderWidth
        borderColor: root.selected || root.onSelectedSurface
            ? Config.ui.selectedBackground
            : root.borderless ? "transparent" : Config.colors.surface1
        blurRegionEnabled: false
    }

    HoverHandler {
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
