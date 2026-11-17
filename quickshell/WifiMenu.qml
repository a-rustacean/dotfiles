import Quickshell
import Quickshell.Networking
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

import "config.js" as Config

Item {
    id: root

    signal passwordPromptClosed()

    readonly property var wifiDevices: Networking.devices.values
        .filter(device => device.type === DeviceType.Wifi)
    readonly property var networks: {
        const all = [];

        for (const device of wifiDevices) {
            for (const network of device.networks.values) {
                const key = network.name + "|" + network.security;
                const existingIndex = all.findIndex(entry =>
                    entry.name + "|" + entry.security === key
                );

                if (existingIndex === -1) {
                    all.push(network);
                } else {
                    const existing = all[existingIndex];
                    if (network.connected
                        || (!existing.connected && network.signalStrength > existing.signalStrength))
                        all[existingIndex] = network;
                }
            }
        }

        return all.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.known !== b.known)
                return a.known ? -1 : 1;
            if (a.signalStrength !== b.signalStrength)
                return b.signalStrength - a.signalStrength;
            return a.name.localeCompare(b.name);
        });
    }

    property bool active: false
    property var scanDevices: []
    property var connectionTarget: null
    property var pendingNetwork: null
    property string password: ""
    property string errorMessage: ""
    readonly property var hostScreen: QsWindow.window?.screen
    implicitHeight: menuContent.implicitHeight

    function startScan() {
        if (!Networking.wifiEnabled)
            return;

        for (const device of wifiDevices) {
            if (!device.scannerEnabled) {
                device.scannerEnabled = true;
                if (!scanDevices.includes(device))
                    scanDevices.push(device);
            }
        }
    }

    function stopScan() {
        for (const device of scanDevices) {
            if (device && device.scannerEnabled)
                device.scannerEnabled = false;
        }
        scanDevices = [];
    }

    function supportsPsk(network) {
        return network.security === WifiSecurityType.WpaPsk
            || network.security === WifiSecurityType.Wpa2Psk
            || network.security === WifiSecurityType.Sae;
    }

    function connectNetwork(network) {
        errorMessage = "";
        pendingNetwork = null;
        connectionTarget = network;
        network.connect();
    }

    function activateNetwork(network) {
        if (!Networking.wifiEnabled || !network
            || network.connected || network.stateChanging)
            return;

        if (!network.known && supportsPsk(network)) {
            errorMessage = "";
            pendingNetwork = network;
            password = "";
            return;
        }

        connectNetwork(network);
    }

    function submitPassword() {
        if (!pendingNetwork || password.length === 0)
            return;

        errorMessage = "";
        connectionTarget = pendingNetwork;
        pendingNetwork.connectWithPsk(password);
        pendingNetwork = null;
        password = "";
        root.passwordPromptClosed();
    }

    function cancelPassword() {
        pendingNetwork = null;
        password = "";
        root.passwordPromptClosed();
    }

    function forgetNetwork(network) {
        network.forget();
        if (pendingNetwork === network) {
            pendingNetwork = null;
            password = "";
        }
    }

    Component.onCompleted: {
        if (active)
            startScan();
    }
    Component.onDestruction: stopScan()
    onWifiDevicesChanged: {
        if (active)
            startScan();
    }
    onActiveChanged: {
        if (active)
            startScan();
        else
            stopScan();
    }

    Connections {
        target: Networking

        function onWifiEnabledChanged() {
            if (root.active && Networking.wifiEnabled)
                root.startScan();
            else
                root.stopScan();
        }
    }

    Connections {
        target: root.connectionTarget

        function onConnectedChanged() {
            if (root.connectionTarget && root.connectionTarget.connected) {
                root.connectionTarget = null;
                root.errorMessage = "";
            }
        }

        function onConnectionFailed(reason) {
            const network = root.connectionTarget;
            root.connectionTarget = null;

            if (reason === ConnectionFailReason.NoSecrets && root.supportsPsk(network)) {
                root.pendingNetwork = network;
                root.password = "";
                root.errorMessage = "";
            } else {
                root.errorMessage = "Connection failed: " + ConnectionFailReason.toString(reason);
            }
        }
    }

    PanelWindow {
        id: passwordPrompt

        visible: root.pendingNetwork !== null
        screen: root.hostScreen
        color: "transparent"
        focusable: true

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell-wifi-password"

        exclusionMode: ExclusionMode.Ignore

        BackgroundEffect.blurRegion: Region {
            item: passwordCard
            radius: Config.ui.rounding
        }

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        onVisibleChanged: {
            if (visible)
                Qt.callLater(() => passwordField.forceActiveFocus());
        }

        Rectangle {
            anchors.fill: parent
            color: "#66000000"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.cancelPassword()
        }

        ThemedRectangle {
            id: passwordCard

            anchors.centerIn: parent
            width: Config.quickSettings.menuWidth
            height: 156
            blurRegionEnabled: false

            MouseArea {
                anchors.fill: parent
                onClicked: event => event.accepted = true
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Config.quickSettings.menuPadding
                spacing: Config.quickSettings.menuSpacing

                Text {
                    Layout.fillWidth: true
                    text: "Connect to " + (root.pendingNetwork?.name || "Wi-Fi")
                    color: Config.colors.text
                    font.family: Config.ui.fontFamily
                    font.pixelSize: Config.quickSettings.titleFontSize
                    font.bold: true
                    elide: Text.ElideRight
                }

                TextField {
                    id: passwordField

                    Layout.fillWidth: true
                    placeholderText: "Wi-Fi password"
                    echoMode: TextInput.Password
                    text: root.password
                    color: Config.colors.text
                    placeholderTextColor: Config.colors.overlay1
                    font.family: Config.ui.fontFamily
                    font.pixelSize: Config.quickSettings.bodyFontSize
                    selectByMouse: true

                    background: ThemedRectangle {
                        borderColor: passwordField.activeFocus
                            ? Config.colors.text
                            : Config.colors.surface1
                        blurRegionEnabled: false
                    }

                    onTextChanged: root.password = text
                    onAccepted: root.submitPassword()
                    Keys.onEscapePressed: root.cancelPassword()
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight

                    MenuIconButton {
                        glyph: "×"
                        actionName: "Cancel Wi-Fi password entry"
                        onClicked: root.cancelPassword()
                    }

                    MenuIconButton {
                        glyph: "✓"
                        actionName: "Connect to Wi-Fi network"
                        enabled: root.password.length > 0
                        onClicked: root.submitPassword()
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: menuContent

        anchors.fill: parent
        spacing: Config.quickSettings.menuSpacing

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: "Wi-Fi"
                    color: Config.colors.text
                    font.family: Config.ui.fontFamily
                    font.pixelSize: Config.quickSettings.titleFontSize
                    font.bold: true
                }

                Text {
                    text: {
                        if (!Networking.wifiEnabled)
                            return "Wi-Fi is off";
                        const connected = root.networks.find(network => network.connected);
                        if (connected)
                            return "";
                        return root.wifiDevices.length > 0
                            ? "Not connected"
                            : "No Wi-Fi adapter";
                    }
                    color: Config.colors.overlay1
                    font.family: Config.ui.fontFamily
                    font.pixelSize: Config.quickSettings.smallFontSize
                    elide: Text.ElideRight
                    visible: text !== ""
                }
            }

        }

        Text {
            Layout.fillWidth: true
            text: root.errorMessage
            color: Config.colors.subtext0
            font.family: Config.ui.fontFamily
            font.pixelSize: Config.quickSettings.smallFontSize
            elide: Text.ElideRight
            visible: text !== ""
        }

        ListView {
            id: networkList

            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: Math.max(contentHeight, Config.quickSettings.rowHeight)
            clip: true
            spacing: 4
            model: root.networks

            delegate: ThemedRectangle {
                id: networkRow
                required property var modelData

                readonly property var network: modelData
                readonly property bool isConnected: network.connected

                width: networkList.width
                height: Config.quickSettings.rowHeight
                backgroundColor: isConnected
                    ? Config.ui.selectedBackground
                    : Config.bar.disabledBackground
                borderSize: isConnected ? Config.ui.borderWidth : 0
                borderColor: isConnected
                    ? Config.ui.selectedBackground
                    : Config.colors.surface1
                blurRegionEnabled: false

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    enabled: Networking.wifiEnabled
                        && !networkRow.isConnected
                        && !networkRow.network.stateChanging
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.activateNetwork(networkRow.network)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 6

                    WifiSignal {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 18
                        strength: networkRow.network.signalStrength
                        selected: networkRow.isConnected
                        marked: !Networking.wifiEnabled
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: networkRow.network.name || "Hidden network"
                            color: networkRow.isConnected
                                ? Config.ui.selectedForeground
                                : Config.colors.text
                            font.family: Config.ui.fontFamily
                            font.pixelSize: Config.quickSettings.bodyFontSize
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: WifiSecurityType.toString(networkRow.network.security)
                                + " · "
                                + Math.round(networkRow.network.signalStrength * 100)
                                + "%"
                                + (networkRow.network.known ? " · Saved" : "")
                            color: networkRow.isConnected
                                ? Config.ui.selectedSecondary
                                : Config.colors.overlay1
                            font.family: Config.ui.fontFamily
                            font.pixelSize: Config.quickSettings.smallFontSize
                            elide: Text.ElideRight
                        }
                    }

                    MenuIconButton {
                        glyph: "󰌸"
                        actionName: "Disconnect from " + networkRow.network.name
                        onSelectedSurface: networkRow.isConnected
                        visible: networkRow.isConnected
                        enabled: Networking.wifiEnabled && !networkRow.network.stateChanging
                        onClicked: networkRow.network.disconnect()
                    }

                    MenuIconButton {
                        glyph: "󰆴"
                        actionName: "Forget Wi-Fi network " + networkRow.network.name
                        onSelectedSurface: networkRow.isConnected
                        visible: networkRow.network.known
                        enabled: visible
                        onClicked: root.forgetNetwork(networkRow.network)
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                width: parent.width - 16
                text: !Networking.wifiEnabled
                    ? "Use the Wi-Fi bar icon to turn Wi-Fi on"
                    : root.wifiDevices.length === 0
                        ? "No Wi-Fi adapter or NetworkManager available"
                        : root.wifiDevices.some(device => device.scannerEnabled)
                            ? "Scanning for networks…"
                            : "No networks found"
                color: Config.colors.overlay1
                font.family: Config.ui.fontFamily
                font.pixelSize: Config.quickSettings.bodyFontSize
                horizontalAlignment: Text.AlignHCenter
                visible: root.networks.length === 0
            }
        }
    }
}
