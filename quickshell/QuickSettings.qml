import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import "config.js" as Config

RowLayout {
    id: root

    property string activeMenu: ""
    property Item anchorItem: null

    readonly property bool hasAudioInput: Pipewire.nodes.values.some(
        node => node.audio !== null && !node.isStream && !node.isSink
    )
    readonly property bool hasAudioOutput: Pipewire.nodes.values.some(
        node => node.audio !== null && !node.isStream && node.isSink
    )
    readonly property bool hasWifiDevice: Networking.devices.values.some(
        device => device.type === DeviceType.Wifi
    )

    readonly property bool inputMuted: {
        const audio = Pipewire.defaultAudioSource?.audio;
        return !audio || audio.muted;
    }
    readonly property bool outputMuted: {
        const audio = Pipewire.defaultAudioSink?.audio;
        return !audio || audio.muted;
    }

    spacing: 4

    function toggleInputMute() {
        const audio = Pipewire.defaultAudioSource?.audio;
        if (audio)
            audio.muted = !audio.muted;
    }

    function toggleOutputMute() {
        const audio = Pipewire.defaultAudioSink?.audio;
        if (audio)
            audio.muted = !audio.muted;
    }

    function toggleBluetooth() {
        const adapter = Bluetooth.defaultAdapter;
        if (adapter)
            adapter.enabled = !adapter.enabled;
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function showMenu(name, item) {
        closeTimer.stop();
        activeMenu = name;
        anchorItem = item;
    }

    function scheduleClose() {
        if (activeMenu === "")
            return;
        if (activeMenu === "wifi" && menuLoader.item?.pendingNetwork)
            return;
        closeTimer.restart();
    }

    BarItem {
        id: inputButton
        implicitWidth: Config.bar.height - Config.bar.margin
        visible: root.hasAudioInput
        active: root.activeMenu === "audio-input"
        Accessible.role: Accessible.Button
        Accessible.name: "Audio input settings"

        StatusIcon {
            anchors.centerIn: parent
            icon: "󰍬"
            marked: root.inputMuted
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleInputMute()
        }

        HoverHandler {
            id: inputHover
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                if (hovered)
                    root.showMenu("audio-input", inputButton);
                else
                    root.scheduleClose();
            }
        }
    }

    BarItem {
        id: outputButton
        implicitWidth: Config.bar.height - Config.bar.margin
        visible: root.hasAudioOutput
        active: root.activeMenu === "audio-output"
        Accessible.role: Accessible.Button
        Accessible.name: "Audio output settings"

        StatusIcon {
            anchors.centerIn: parent
            icon: "󰕾"
            marked: root.outputMuted
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleOutputMute()
        }

        HoverHandler {
            id: outputHover
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                if (hovered)
                    root.showMenu("audio-output", outputButton);
                else
                    root.scheduleClose();
            }
        }
    }

    BarItem {
        id: bluetoothButton
        implicitWidth: Config.bar.height - Config.bar.margin
        visible: Bluetooth.defaultAdapter !== null
        active: root.activeMenu === "bluetooth"
        Accessible.role: Accessible.Button
        Accessible.name: "Bluetooth settings"

        StatusIcon {
            anchors.centerIn: parent
            icon: "󰂯"
            marked: !Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled
        }

        MouseArea {
            anchors.fill: parent
            enabled: Bluetooth.defaultAdapter !== null
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleBluetooth()
        }

        HoverHandler {
            id: bluetoothHover
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                if (hovered)
                    root.showMenu("bluetooth", bluetoothButton);
                else
                    root.scheduleClose();
            }
        }
    }

    BarItem {
        id: wifiButton
        implicitWidth: Config.bar.height - Config.bar.margin
        visible: root.hasWifiDevice
        active: root.activeMenu === "wifi"
        Accessible.role: Accessible.Button
        Accessible.name: "Wi-Fi settings"

        StatusIcon {
            anchors.centerIn: parent
            icon: "󰖩"
            marked: !Networking.wifiEnabled
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleWifi()
        }

        HoverHandler {
            id: wifiHover
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                if (hovered)
                    root.showMenu("wifi", wifiButton);
                else
                    root.scheduleClose();
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 250
        repeat: false
        onTriggered: {
            if (inputHover.hovered || outputHover.hovered
                || bluetoothHover.hovered || wifiHover.hovered
                || popupHover.hovered) {
                return;
            }
            if (root.activeMenu === "wifi" && menuLoader.item?.pendingNetwork)
                return;

            root.activeMenu = "";
            root.anchorItem = null;
        }
    }

    PopupWindow {
        id: popup

        visible: root.activeMenu !== "" && root.anchorItem !== null
        grabFocus: false
        color: "transparent"
        implicitWidth: Config.quickSettings.menuWidth
        implicitHeight: Math.max(1, Math.min(
            Config.quickSettings.menuHeight,
            popup.screen
                ? popup.screen.height - Config.bar.height - Config.quickSettings.screenMargin
                : Config.quickSettings.menuHeight,
            menuLoader.implicitHeight + Config.quickSettings.menuPadding * 2
        ))

        onVisibleChanged: {
            if (!visible && root.activeMenu !== "") {
                root.activeMenu = "";
                root.anchorItem = null;
            }
        }

        anchor {
            item: root.anchorItem
            rect.x: root.anchorItem ? (root.anchorItem.width - popup.width) / 2 : 0
            rect.y: root.anchorItem
                ? root.anchorItem.height + Config.quickSettings.menuGap
                : 0
            rect.width: 1
            rect.height: 1
            edges: Edges.Bottom | Edges.Left
            gravity: Edges.Bottom | Edges.Right
            margins.bottom: 0
            adjustment: PopupAdjustment.SlideX
        }

        Item {
            anchors.fill: parent

            HoverHandler {
                id: popupHover

                onHoveredChanged: {
                    if (hovered)
                        closeTimer.stop();
                    else
                        root.scheduleClose();
                }
            }

            ThemedRectangle {
                id: menuFrame

                anchors {
                    fill: parent
                }

                blurRegionEnabled: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Config.quickSettings.menuPadding

                    Loader {
                        id: menuLoader
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        active: popup.visible

                        sourceComponent: {
                            switch (root.activeMenu) {
                            case "audio-input":
                                return inputMenu;
                            case "audio-output":
                                return outputMenu;
                            case "bluetooth":
                                return bluetoothMenu;
                            case "wifi":
                                return wifiMenu;
                            default:
                                return null;
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: inputMenu
        AudioMenu {
            inputSource: true
        }
    }

    Component {
        id: outputMenu
        AudioMenu {
            inputSource: false
        }
    }

    Component {
        id: bluetoothMenu
        BluetoothMenu {
            active: true
        }
    }

    Component {
        id: wifiMenu
        WifiMenu {
            active: true
            onPasswordPromptClosed: root.scheduleClose()
        }
    }

    onAnchorItemChanged: {
        if (popup.visible)
            Qt.callLater(() => popup.anchor.updateAnchor());
    }
}
