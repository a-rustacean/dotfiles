import Quickshell
import QtQuick

import "config.js" as Config

Rectangle {
    id: root

    property color backgroundColor: Config.bar.background
    property color borderColor: Config.colors.surface1
    property int borderSize: Config.ui.borderWidth
    property int cornerRadius: Config.ui.rounding
    property bool blurRegionEnabled: true

    readonly property Region blurRegion: Region {
        item: root
        radius: root.cornerRadius
    }

    color: backgroundColor
    border.width: borderSize
    border.color: borderColor
    radius: cornerRadius
}
