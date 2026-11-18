import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects

import qs

PanelWindow {
    id: root

    default property alias contentData: promptCard.data

    property string layerNamespace: "quickshell-prompt"
    property var targetScreen: null
    property int cardWidth: 480
    property int cardHeight: 320
    property int cardRadius: Config.ui.rounding
    property color cardBackground: Config.bar.background
    property color cardBorderColor: Config.colors.surface1
    property int cardBorderSize: Config.ui.borderWidth
    property bool cardBorderless: false
    property bool dismissOnBackdropClick: true
    property color backdropColor: "#66000000"

    signal dismissed

    screen: root.targetScreen
    color: "transparent"
    focusable: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: root.layerNamespace

    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    BackgroundEffect.blurRegion: Region {
        item: promptCard
        radius: root.cardRadius
    }

    Rectangle {
        anchors.fill: parent
        color: root.backdropColor
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.dismissOnBackdropClick
        onClicked: root.dismissed()
    }

    ThemedRectangle {
        id: promptCard

        anchors.centerIn: parent
        width: root.cardWidth
        height: root.cardHeight
        cornerRadius: root.cardRadius
        defaultBackgroundColor: root.cardBackground
        borderColor: root.cardBorderColor
        borderSize: root.cardBorderSize
        borderless: root.cardBorderless
        blurRegionEnabled: false

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: event => event.accepted = true
        }
    }
}
