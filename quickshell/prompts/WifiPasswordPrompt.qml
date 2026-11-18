import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import qs

Prompt {
    id: root

    property string networkName: ""
    property string password: ""

    signal passwordEdited(string value)
    signal submitRequested()
    signal cancelRequested()

    layerNamespace: "quickshell-wifi-password"
    cardWidth: Config.quickSettings.menuWidth
    cardHeight: 156
    dismissOnBackdropClick: true

    onDismissed: root.cancelRequested()
    onVisibleChanged: {
        if (visible)
            Qt.callLater(() => passwordField.forceActiveFocus());
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Config.quickSettings.menuPadding
        spacing: Config.quickSettings.menuSpacing

        Text {
            Layout.fillWidth: true
            text: "Connect to " + (root.networkName || "Wi-Fi")
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
                highlighted: passwordField.activeFocus
                blurRegionEnabled: false
            }

            onTextChanged: {
                if (root.password !== text)
                    root.passwordEdited(text);
            }
            onAccepted: root.submitRequested()
            Keys.onEscapePressed: root.cancelRequested()
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight

            MenuIconButton {
                glyph: "×"
                actionName: "Cancel Wi-Fi password entry"
                onClicked: root.cancelRequested()
            }

            MenuIconButton {
                glyph: "✓"
                actionName: "Connect to Wi-Fi network"
                enabled: root.password.length > 0
                onClicked: root.submitRequested()
            }
        }
    }
}
