import QtQuick

import "../config.js" as Config

ThemedRectangle {
    id: root

    implicitWidth: 100
    implicitHeight: Config.bar.height - Config.bar.margin

    trackHover: true
}
