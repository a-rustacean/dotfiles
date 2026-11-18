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
    property var bluetoothDiscoveryOwnerAdapter: null

    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property bool bluetoothMenuOpen: root.activeMenu === "bluetooth"
    readonly property bool hasAudioInput: Pipewire.nodes.values.some(node => node.audio !== null && !node.isStream && !node.isSink)
    readonly property bool hasAudioOutput: Pipewire.nodes.values.some(node => node.audio !== null && !node.isStream && node.isSink)
    readonly property bool hasWifiDevice: Networking.devices.values.some(device => device.type === DeviceType.Wifi)
    readonly property bool bluetoothConnected: root.bluetoothAdapter !== null && root.bluetoothAdapter.devices.values.some(device => device.connected)
    readonly property bool wifiConnected: Networking.devices.values.filter(device => device.type === DeviceType.Wifi).some(device => device.networks.values.some(network => network.connected))

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
        if (!root.bluetoothMenuOpen) {
            root.bluetoothDiscoveryPending = false;
            root.bluetoothDiscoveryAdapter = null;
            return;
        }

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
        root.bluetoothDiscoveryOwnerAdapter = adapter;
        adapter.discovering = true;
    }

    function stopBluetoothDiscovery() {
        const adapter = root.bluetoothAdapter;
        if (adapter && adapter.discovering && root.bluetoothDiscoveryOwnerAdapter === adapter)
            adapter.discovering = false;

        root.bluetoothDiscoveryPending = false;
        root.bluetoothDiscoveryAdapter = null;
        root.bluetoothDiscoveryOwnerAdapter = null;
    }

    function connectBluetoothDevice(device) {
        if (!device || !root.bluetoothAdapter || !root.bluetoothAdapter.enabled || bluetoothConnectProcess.running || root.bluetoothForgettingDevice)
            return;

        bluetoothConnectionError = "";
        bluetoothConnectingDevice = device;
        bluetoothConnectProcess.command = ["bluetoothctl", "--agent", "NoInputNoOutput", "connect", device.address];
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

    onBluetoothMenuOpenChanged: {
        if (bluetoothMenuOpen)
            ensureBluetoothDiscovery();
        else
            stopBluetoothDiscovery();
    }

    Connections {
        target: Bluetooth

        function onDefaultAdapterChanged() {
            if (root.bluetoothMenuOpen)
                root.ensureBluetoothDiscovery();
        }
    }

    Connections {
        target: root.bluetoothAdapter

        function onEnabledChanged() {
            if (root.bluetoothMenuOpen)
                root.ensureBluetoothDiscovery();
            else
                root.stopBluetoothDiscovery();
        }

        function onDiscoveringChanged() {
            if (root.bluetoothAdapter?.discovering) {
                root.bluetoothDiscoveryPending = false;
                root.bluetoothDiscoveryAdapter = null;
            } else if (root.bluetoothMenuOpen && root.bluetoothAdapter?.enabled && !bluetoothConnectProcess.running) {
                root.bluetoothDiscoveryOwnerAdapter = null;
                Qt.callLater(() => root.ensureBluetoothDiscovery());
            } else {
                root.bluetoothDiscoveryOwnerAdapter = null;
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
                root.bluetoothConnectionError = failure || "Bluetooth connection failed; check that Bluetooth is enabled";
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

    QuickSettingsButton {
        id: inputButton
        icon: "󰍬"
        menuName: "audio-input"
        accessibleName: "Audio input settings"
        toggleAction: root.toggleInputMute
        menuController: root
        visible: root.hasAudioInput
        visualState: root.inputMuted ? Config.states.disabled : Config.states.defaultState
    }

    QuickSettingsButton {
        id: outputButton
        icon: "󰕾"
        menuName: "audio-output"
        accessibleName: "Audio output settings"
        toggleAction: root.toggleOutputMute
        menuController: root
        visible: root.hasAudioOutput
        visualState: root.outputMuted ? Config.states.disabled : Config.states.defaultState
    }

    QuickSettingsButton {
        id: bluetoothButton
        icon: "󰂯"
        menuName: "bluetooth"
        accessibleName: "Bluetooth settings"
        toggleAction: root.toggleBluetooth
        menuController: root
        visible: Bluetooth.defaultAdapter !== null
        toggleEnabled: root.bluetoothAdapter !== null
        visualState: root.bluetoothAdapter?.enabled ? root.bluetoothConnected ? Config.states.active : Config.states.defaultState : Config.states.disabled
    }

    QuickSettingsButton {
        id: wifiButton
        icon: "󰖩"
        menuName: "wifi"
        accessibleName: "Wi-Fi settings"
        toggleAction: root.toggleWifi
        menuController: root
        visible: root.hasWifiDevice
        visualState: Networking.wifiEnabled ? root.wifiConnected ? Config.states.active : Config.states.defaultState : Config.states.disabled
    }

    Timer {
        id: closeTimer
        interval: 250
        repeat: false
        onTriggered: {
            if (inputButton.hovered || outputButton.hovered || bluetoothButton.hovered || wifiButton.hovered || popupHover.hovered) {
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
        implicitHeight: Math.max(1, Math.min(Config.quickSettings.menuHeight, popup.screen ? popup.screen.height - Config.bar.height - Config.quickSettings.screenMargin : Config.quickSettings.menuHeight, menuLoader.implicitHeight + Config.quickSettings.menuPadding * 2))

        onVisibleChanged: {
            if (!visible && root.activeMenu !== "") {
                root.activeMenu = "";
                root.anchorItem = null;
            }
        }

        anchor {
            item: root.anchorItem
            rect.x: root.anchorItem ? (root.anchorItem.width - popup.width) / 2 : 0
            rect.y: root.anchorItem ? root.anchorItem.height + Config.quickSettings.menuGap : 0
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
