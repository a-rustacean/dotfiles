import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import "../components"
import qs
import "../menus"

RowLayout {
    id: root

    property string activeMenu: ""
    property Item anchorItem: null
    property var bluetoothConnectingDevice: null
    property var bluetoothForgettingDevice: null
    property string bluetoothConnectionError: ""
    property bool bluetoothDiscoveryPending: false
    property var bluetoothDiscoveryAdapter: null

    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property bool hasAudioInput: Pipewire.nodes.values.some(
        node => node.audio !== null && !node.isStream && !node.isSink
    )
    readonly property bool hasAudioOutput: Pipewire.nodes.values.some(
        node => node.audio !== null && !node.isStream && node.isSink
    )
    readonly property bool hasWifiDevice: Networking.devices.values.some(
        device => device.type === DeviceType.Wifi
    )
    readonly property bool bluetoothConnected: root.bluetoothAdapter !== null
        && root.bluetoothAdapter.devices.values.some(device => device.connected)
    readonly property bool wifiConnected: Networking.devices.values
        .filter(device => device.type === DeviceType.Wifi)
        .some(device => device.networks.values.some(network => network.connected))

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSource, Pipewire.defaultAudioSink]
    }

    readonly property bool inputMuted: {
        const node = Pipewire.defaultAudioSource;
        return !node || !node.ready || node.audio === null || node.audio.muted;
    }
    readonly property bool outputMuted: {
        const node = Pipewire.defaultAudioSink;
        return !node || !node.ready || node.audio === null || node.audio.muted;
    }

    spacing: 4

    function toggleInputMute() {
        const node = Pipewire.defaultAudioSource;
        if (node && node.ready && node.audio !== null)
            node.audio.muted = !node.audio.muted;
    }

    function toggleOutputMute() {
        const node = Pipewire.defaultAudioSink;
        if (node && node.ready && node.audio !== null)
            node.audio.muted = !node.audio.muted;
    }

    function toggleBluetooth() {
        const adapter = root.bluetoothAdapter;
        if (adapter)
            adapter.enabled = !adapter.enabled;
    }

    function ensureBluetoothDiscovery() {
        const adapter = root.bluetoothAdapter;
        if (!adapter || !adapter.enabled || bluetoothConnectProcess.running) {
            root.bluetoothDiscoveryPending = false;
            root.bluetoothDiscoveryAdapter = null;
            return;
        }

        if (adapter.discovering) {
            root.bluetoothDiscoveryPending = false;
            root.bluetoothDiscoveryAdapter = null;
            return;
        }

        if (root.bluetoothDiscoveryPending && root.bluetoothDiscoveryAdapter === adapter)
            return;

        root.bluetoothDiscoveryPending = true;
        root.bluetoothDiscoveryAdapter = adapter;
        adapter.discovering = true;
    }

    function connectBluetoothDevice(device) {
        if (!device || !root.bluetoothAdapter || !root.bluetoothAdapter.enabled
            || bluetoothConnectProcess.running || root.bluetoothForgettingDevice)
            return;

        bluetoothConnectionError = "";
        bluetoothConnectingDevice = device;
        bluetoothConnectProcess.command = [
            "bluetoothctl",
            "--agent",
            "NoInputNoOutput",
            "connect",
            device.address
        ];
        bluetoothConnectProcess.running = true;
        if (root.bluetoothAdapter.discovering)
            root.bluetoothAdapter.discovering = false;
    }

    function forgetBluetoothDevice(device) {
        if (!device || root.bluetoothForgettingDevice)
            return;

        if (!device.connected) {
            device.forget();
            return;
        }

        root.bluetoothForgettingDevice = device;
        device.disconnect();
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    Component.onCompleted: ensureBluetoothDiscovery()

    Connections {
        target: Bluetooth

        function onDefaultAdapterChanged() {
            root.ensureBluetoothDiscovery();
        }
    }

    Connections {
        target: root.bluetoothAdapter

        function onEnabledChanged() {
            root.ensureBluetoothDiscovery();
        }

        function onDiscoveringChanged() {
            if (root.bluetoothAdapter?.discovering) {
                root.bluetoothDiscoveryPending = false;
                root.bluetoothDiscoveryAdapter = null;
            } else if (root.bluetoothAdapter?.enabled && !bluetoothConnectProcess.running) {
                Qt.callLater(() => root.ensureBluetoothDiscovery());
            }
        }
    }

    Connections {
        target: root.bluetoothForgettingDevice

        function onConnectedChanged() {
            const device = root.bluetoothForgettingDevice;
            if (device && !device.connected) {
                root.bluetoothForgettingDevice = null;
                device.forget();
            }
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: root.bluetoothAdapter !== null
            && root.bluetoothAdapter.enabled
            && !root.bluetoothAdapter.discovering
            && !bluetoothConnectProcess.running
        onTriggered: {
            root.bluetoothDiscoveryPending = false;
            root.ensureBluetoothDiscovery();
        }
    }

    Process {
        id: bluetoothConnectProcess

        stdout: StdioCollector {
            id: bluetoothConnectStdout
        }

        stderr: StdioCollector {
            id: bluetoothConnectStderr
        }

        onExited: (exitCode, exitStatus) => {
            const output = (bluetoothConnectStdout.text + "\n" + bluetoothConnectStderr.text).trim();
            const failure = output.split("\n").find(line => /failed|error/i.test(line));
            if (exitCode !== 0 || failure) {
                root.bluetoothConnectionError = failure
                    || "Bluetooth connection failed; check that Bluetooth is enabled";
            }

            root.bluetoothConnectingDevice = null;
            root.bluetoothDiscoveryPending = false;
            Qt.callLater(() => root.ensureBluetoothDiscovery());
        }
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
        visualState: root.inputMuted ? Config.states.disabled : Config.states.defaultState
        highlighted: root.activeMenu === "audio-input"
        Accessible.role: Accessible.Button
        Accessible.name: "Audio input settings"

        StatusIcon {
            anchors.centerIn: parent
            icon: "󰍬"
            visualState: inputButton.visualState
            theme: inputButton.resolvedTheme
            hovered: inputButton.hovered
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
        visualState: root.outputMuted ? Config.states.disabled : Config.states.defaultState
        highlighted: root.activeMenu === "audio-output"
        Accessible.role: Accessible.Button
        Accessible.name: "Audio output settings"

        StatusIcon {
            anchors.centerIn: parent
            icon: "󰕾"
            visualState: outputButton.visualState
            theme: outputButton.resolvedTheme
            hovered: outputButton.hovered
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
        visualState: root.bluetoothAdapter?.enabled
            ? root.bluetoothConnected ? Config.states.active : Config.states.defaultState
            : Config.states.disabled
        highlighted: root.activeMenu === "bluetooth"
        Accessible.role: Accessible.Button
        Accessible.name: "Bluetooth settings"

        StatusIcon {
            anchors.centerIn: parent
            icon: "󰂯"
            visualState: bluetoothButton.visualState
            theme: bluetoothButton.resolvedTheme
            hovered: bluetoothButton.hovered
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.bluetoothAdapter !== null
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
        visualState: Networking.wifiEnabled
            ? root.wifiConnected ? Config.states.active : Config.states.defaultState
            : Config.states.disabled
        highlighted: root.activeMenu === "wifi"
        Accessible.role: Accessible.Button
        Accessible.name: "Wi-Fi settings"

        StatusIcon {
            anchors.centerIn: parent
            icon: "󰖩"
            visualState: wifiButton.visualState
            theme: wifiButton.resolvedTheme
            hovered: wifiButton.hovered
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
            connectingDevice: root.bluetoothConnectingDevice
            forgettingDevice: root.bluetoothForgettingDevice
            connectionError: root.bluetoothConnectionError
            onConnectRequested: device => root.connectBluetoothDevice(device)
            onForgetRequested: device => root.forgetBluetoothDevice(device)
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
