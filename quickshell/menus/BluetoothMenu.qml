import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

import "../components"
import qs

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
    property var connectingDevice: null
    property var forgettingDevice: null
    property string connectionError: ""

    signal connectRequested(var device)
    signal forgetRequested(var device)

    implicitHeight: menuContent.implicitHeight

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
            || device.connected || device.pairing || root.connectingDevice || root.forgettingDevice)
            return;

        root.connectRequested(device);
    }

    ColumnLayout {
        id: menuContent

        anchors.fill: parent
        spacing: 0

        Text {
            Layout.fillWidth: true
            text: "Bluetooth"
            color: Config.colors.text
            font.family: Config.ui.fontFamily
            font.pixelSize: Config.quickSettings.titleFontSize
            font.bold: true
        }

        Text {
            Layout.fillWidth: true
            text: root.connectionError
            color: Config.colors.red
            font.family: Config.ui.fontFamily
            font.pixelSize: Config.quickSettings.smallFontSize
            elide: Text.ElideRight
            visible: text !== ""
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
                    id: deviceSurface
                    anchors.fill: parent
                    visible: deviceRow.device !== null
                    visualState: deviceRow.isConnected ? Config.states.active : Config.states.defaultState
                    trackHover: true
                    borderless: !deviceRow.isConnected
                    blurRegionEnabled: false

                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        enabled: root.adapter !== null
                            && root.adapter.enabled
                            && deviceRow.device !== null
                            && !deviceRow.isConnected
                            && !deviceRow.device.pairing
                            && !root.connectingDevice
                            && !root.forgettingDevice
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
                            visualState: deviceRow.isConnected ? Config.states.active : Config.states.defaultState
                            theme: deviceSurface.resolvedTheme
                            hovered: deviceSurface.hovered
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: deviceRow.device
                                ? (deviceRow.device.name || deviceRow.device.deviceName || "Unknown device")
                                : ""
                                color: deviceSurface.resolvedForegroundColor
                                font.family: Config.ui.fontFamily
                                font.pixelSize: Config.quickSettings.bodyFontSize
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: {
                                    if (!deviceRow.device)
                                    return "";
                                    if (root.forgettingDevice === deviceRow.device)
                                    return deviceRow.device.connected
                                        ? "Disconnecting before forgetting…"
                                        : "Forgetting…";
                                    if (deviceRow.device.connected)
                                    return deviceRow.device.batteryAvailable
                                    ? "Connected · " + Math.round(deviceRow.device.battery * 100) + "%"
                                    : "Connected";
                                    if (deviceRow.device.pairing)
                                    return "Pairing…";
                                    if (root.connectingDevice === deviceRow.device)
                                    return "Connecting…";
                                    return deviceRow.device.paired ? "Paired" : "Nearby";
                                }
                                color: deviceSurface.resolvedSecondaryColor
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
                            theme: deviceSurface.resolvedTheme
                            visible: deviceRow.isConnected
                            enabled: root.adapter !== null && root.adapter.enabled
                            onClicked: deviceRow.device.disconnect()
                        }

                        MenuIconButton {
                            glyph: "󰆴"
                            actionName: deviceRow.device
                                ? "Forget " + deviceRow.device.name
                                : "Forget Bluetooth device"
                            theme: deviceSurface.resolvedTheme
                            visible: deviceRow.device !== null && deviceRow.device.paired
                            enabled: visible && !root.forgettingDevice
                            onClicked: root.forgetRequested(deviceRow.device)
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
                ? root.adapter.discovering
                    ? "Scanning for devices…"
                    : "Waiting for Bluetooth discovery…"
                : "Turn Bluetooth on to see devices"
                color: Config.colors.overlay1
                font.family: Config.ui.fontFamily
                font.pixelSize: Config.quickSettings.bodyFontSize
                horizontalAlignment: Text.AlignHCenter
                visible: root.deviceEntries.length === 0
            }
        }
    }
}
