import QtQuick

import qs

BarItem {
    id: root

    property string icon: ""
    property string menuName: ""
    property string accessibleName: ""
    property var toggleAction: null
    property var menuController: null
    property bool toggleEnabled: true

    implicitWidth: Config.bar.height - Config.bar.margin
    highlighted: root.menuController
        ? root.menuController.activeMenu === root.menuName
        : false
    Accessible.role: Accessible.Button
    Accessible.name: root.accessibleName

    StatusIcon {
        anchors.centerIn: parent
        icon: root.icon
        visualState: root.visualState
        theme: root.resolvedTheme
        hovered: root.hovered
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.toggleEnabled
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.toggleAction)
                root.toggleAction();
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
            if (!root.menuController)
                return;
            if (hovered)
                root.menuController.showMenu(root.menuName, root);
            else
                root.menuController.scheduleClose();
        }
    }
}
