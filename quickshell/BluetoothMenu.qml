import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "config.js" as Config

Item {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter ? adapter.devices.values : []
    readonly property var deviceEntries: {
        const paired = devices.filter(device => device.paired)
        .sort((a, b) => a.name.localeCompare(b.name));
        const nearby = devices.filter(device => !device.paired)
        .sort((a, b) => a.name.localeCompare(b.name));
        const entries = [];

        if (paired.length > 0) {
            entries.push({ section: "Paired devices" });
            for (const device of paired)
            entries.push({ device });
        }

        if (nearby.length > 0) {
            entries.push({ section: "Nearby devices" });
            for (const device of nearby)
            entries.push({ device });
        }

        return entries;
    }
    property bool active: false
    property bool ownsScan: false
    property bool scanStartPending: false
    property bool scanWasDiscovering: false
    property var scanAdapter: null
    property var pairingDevice: null
    property var connectAfterPairDevice: null
    property string pairingError: ""
    implicitHeight: menuContent.implicitHeight

    function pairAndConnect(device) {
        if (pairingProcess.running || !device)
        return;

        pairingError = "";
        pairingDevice = device;
        connectAfterPairDevice = device;
        pairingProcess.command = [
        "bluetoothctl",
        "--timeout",
        "30",
        "--agent",
        "NoInputNoOutput",
        "pair",
        device.address
        ];
        pairingProcess.running = true;
    }

    function deviceGlyph(device) {
        const icon = device
            ? ((device.icon || "") + " " + (device.name || "")).toLowerCase()
            : "";
        if (icon.includes("phone") || icon.includes("mobile"))
            return "󰄜";
        if (icon.includes("headphone"))
            return "󰋋";
        if (icon.includes("headset"))
            return "󰋎";
        if (icon.includes("speaker") || icon.includes("audio-card"))
            return "󰓃";
        if (icon.includes("keyboard"))
            return "󰌌";
        if (icon.includes("mouse"))
            return "󰍽";
        if (icon.includes("computer") || icon.includes("laptop"))
            return "󰌢";
        return "󰂯";
    }

    function activateDevice(device) {
        if (!device || !adapter || !adapter.enabled
            || device.connected || device.pairing || pairingProcess.running
            || (pairingDevice && pairingDevice !== device))
            return;

        if (device.paired)
            device.connect();
        else
            pairAndConnect(device);
    }

    function startScan() {
        if (!adapter || !adapter.enabled)
            return;

        if (adapter.discovering) {
            scanStartPending = false;
            scanWasDiscovering = true;
            return;
        }

        // BlueZ reports the discovery state asynchronously; don't issue a
        // second StartDiscovery while the first request is still pending.
        if (scanStartPending && scanAdapter === adapter)
            return;

        scanStartPending = true;
        ownsScan = true;
        scanAdapter = adapter;
        adapter.discovering = true;
    }

    function stopScan() {
        if (ownsScan && scanAdapter && scanAdapter.discovering)
            scanAdapter.discovering = false;
        ownsScan = false;
        scanAdapter = null;
        scanStartPending = false;
        scanWasDiscovering = false;
    }

    Component.onCompleted: {
        if (active)
        startScan();
    }
    Component.onDestruction: stopScan()
    onAdapterChanged: {
        stopScan();
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
        target: root.adapter

        function onEnabledChanged() {
            if (root.active && root.adapter.enabled)
            root.startScan();
            else
            root.stopScan();
        }

        function onDiscoveringChanged() {
            if (root.adapter.discovering) {
                root.scanStartPending = false;
                root.scanWasDiscovering = true;
            } else if (root.scanWasDiscovering) {
                root.scanWasDiscovering = false;
                if (root.active && root.adapter.enabled)
                    Qt.callLater(() => root.startScan());
            }
        }
    }

    ColumnLayout {
        id: menuContent

        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true

                Text {
                    text: "Bluetooth"
                    color: Config.colors.text
                    font.family: Config.ui.fontFamily
                    font.pixelSize: Config.quickSettings.titleFontSize
                    font.bold: true
                }
            }

        }

        ListView {
            id: deviceList

            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: Math.max(contentHeight, Config.quickSettings.rowHeight)
            clip: true
            spacing: 4
            model: root.deviceEntries

            delegate: Item {
                id: deviceRow
                required property var modelData

                readonly property var device: modelData.device ?? null
                readonly property bool isConnected: device !== null && device.connected

                width: deviceList.width
                height: modelData.section
                    ? Config.quickSettings.smallFontSize + 4
                    : Config.quickSettings.rowHeight

                Text {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    text: deviceRow.modelData.section ?? ""
                    color: Config.colors.subtext0
                    font.family: Config.ui.fontFamily
                    font.pixelSize: Config.quickSettings.smallFontSize
                    font.bold: true
                    visible: deviceRow.device === null
                }

                ThemedRectangle {
                    anchors.fill: parent
                    visible: deviceRow.device !== null
                    backgroundColor: deviceRow.isConnected
                    ? Config.ui.selectedBackground
                    : Config.bar.disabledBackground
                    borderColor: deviceRow.isConnected
                    ? Config.ui.selectedBackground
                    : Config.colors.surface1
                    blurRegionEnabled: false

                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        enabled: root.adapter !== null
                            && root.adapter.enabled
                            && deviceRow.device !== null
                            && !deviceRow.isConnected
                            && !deviceRow.device.pairing
                            && !pairingProcess.running
                            && (!root.pairingDevice || root.pairingDevice === deviceRow.device)
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.activateDevice(deviceRow.device)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        StatusIcon {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 20
                            icon: root.deviceGlyph(deviceRow.device)
                            color: deviceRow.isConnected
                            ? Config.ui.selectedForeground
                            : Config.colors.text
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: deviceRow.device
                                ? (deviceRow.device.name || deviceRow.device.deviceName || "Unknown device")
                                : ""
                                color: deviceRow.isConnected
                                ? Config.ui.selectedForeground
                                : Config.colors.text
                                font.family: Config.ui.fontFamily
                                font.pixelSize: Config.quickSettings.bodyFontSize
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: {
                                    if (!deviceRow.device)
                                    return "";
                                    if (root.pairingDevice === deviceRow.device)
                                    return "Pairing…";
                                    if (deviceRow.device.pairing)
                                    return "Pairing…";
                                    if (deviceRow.device.connected)
                                    return deviceRow.device.batteryAvailable
                                    ? "Connected · " + Math.round(deviceRow.device.battery * 100) + "%"
                                    : "Connected";
                                    return deviceRow.device.paired ? "Paired" : "Nearby";
                                }
                                color: deviceRow.isConnected
                                ? Config.ui.selectedSecondary
                                : Config.colors.overlay1
                                font.family: Config.ui.fontFamily
                                font.pixelSize: Config.quickSettings.smallFontSize
                                elide: Text.ElideRight
                            }
                        }

                        MenuIconButton {
                            glyph: "󰌸"
                            actionName: deviceRow.device
                                ? "Disconnect " + deviceRow.device.name
                                : "Disconnect Bluetooth device"
                            onSelectedSurface: deviceRow.isConnected
                            visible: deviceRow.isConnected
                            enabled: root.adapter !== null && root.adapter.enabled
                            onClicked: deviceRow.device.disconnect()
                        }

                        MenuIconButton {
                            glyph: "󰆴"
                            actionName: deviceRow.device
                                ? "Forget " + deviceRow.device.name
                                : "Forget Bluetooth device"
                            onSelectedSurface: deviceRow.isConnected
                            visible: deviceRow.device !== null && deviceRow.device.paired
                            enabled: visible
                            onClicked: deviceRow.device.forget()
                        }
                    }
                }

                Connections {
                    target: deviceRow.device

                    function onPairedChanged() {
                        if (root.connectAfterPairDevice === deviceRow.device && deviceRow.device.paired) {
                            const pairedDevice = root.connectAfterPairDevice;
                            root.connectAfterPairDevice = null;
                            if (!pairedDevice.connected)
                            pairedDevice.connect();
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                width: parent.width - 16
                text: !root.adapter
                ? "No Bluetooth adapter found"
                : root.adapter.enabled
                ? "No devices found yet"
                : "Turn Bluetooth on to see devices"
                color: Config.colors.overlay1
                font.family: Config.ui.fontFamily
                font.pixelSize: Config.quickSettings.bodyFontSize
                horizontalAlignment: Text.AlignHCenter
                visible: root.deviceEntries.length === 0
            }
        }
    }

    Process {
        id: pairingProcess

        stdout: StdioCollector {
            id: pairingStdout
        }

        stderr: StdioCollector {
            id: pairingStderr
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && root.pairingDevice) {
                const output = (pairingStdout.text + "\n" + pairingStderr.text).trim();
                root.pairingError = output !== ""
                ? "Pairing failed: " + output.split("\n").pop()
                : "Pairing failed; check that Bluetooth is enabled";
                if (root.connectAfterPairDevice === root.pairingDevice)
                root.connectAfterPairDevice = null;
            } else if (root.connectAfterPairDevice && root.connectAfterPairDevice.paired) {
                const pairedDevice = root.connectAfterPairDevice;
                root.connectAfterPairDevice = null;
                if (!pairedDevice.connected)
                pairedDevice.connect();
            }

            root.pairingDevice = null;
        }
    }
}
