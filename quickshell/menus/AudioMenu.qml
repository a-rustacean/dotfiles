import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import qs

Item {
    id: root

    property bool inputSource: false
    implicitHeight: menuContent.implicitHeight

    function useNode(node) {
        if (root.inputSource)
            Pipewire.preferredDefaultAudioSource = node;
        else
            Pipewire.preferredDefaultAudioSink = node;
    }

    readonly property var nodes: Pipewire.nodes.values
        .filter(node => node.audio !== null && !node.isStream && node.isSink !== inputSource)
        .sort((a, b) => {
            const defaultNode = inputSource
                ? Pipewire.defaultAudioSource
                : Pipewire.defaultAudioSink;
            if (defaultNode && a.id === defaultNode.id)
                return -1;
            if (defaultNode && b.id === defaultNode.id)
                return 1;
            return (a.description || a.name).localeCompare(b.description || b.name);
        })

    PwObjectTracker {
        objects: root.nodes
    }

    ColumnLayout {
        id: menuContent

        anchors.fill: parent
        spacing: Config.quickSettings.menuSpacing

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: root.inputSource ? "Audio input" : "Audio output"
                color: Config.colors.text
                font.family: Config.ui.fontFamily
                font.pixelSize: Config.quickSettings.titleFontSize
                font.bold: true
            }

            Text {
                text: Pipewire.ready ? "" : "Connecting…"
                color: Config.colors.overlay1
                font.family: Config.ui.fontFamily
                font.pixelSize: Config.quickSettings.smallFontSize
            }
        }

        ListView {
            id: deviceList

            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: Math.max(contentHeight, Config.quickSettings.rowHeight)
            clip: true
            spacing: Config.quickSettings.menuSpacing
            model: root.nodes

            delegate: ThemedRectangle {
                id: deviceRow
                required property var modelData

                readonly property var node: modelData
                readonly property var audio: node.ready ? node.audio : null
                readonly property var defaultNode: root.inputSource
                    ? Pipewire.defaultAudioSource
                    : Pipewire.defaultAudioSink
                readonly property bool isDefault: defaultNode !== null && node.id === defaultNode.id

                width: deviceList.width
                height: Config.quickSettings.rowHeight + Config.quickSettings.audioRowInset * 2
                visualState: deviceRow.isDefault ? Config.states.active : Config.states.defaultState
                trackHover: true
                borderless: !deviceRow.isDefault
                blurRegionEnabled: false

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    enabled: !deviceRow.isDefault
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.useNode(deviceRow.node)
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        leftMargin: 8
                        rightMargin: 8
                        topMargin: Config.quickSettings.audioRowInset
                        bottomMargin: Config.quickSettings.audioRowInset
                    }
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            Layout.fillWidth: true
                            text: deviceRow.node.description || deviceRow.node.nickname || deviceRow.node.name
                            color: deviceRow.resolvedForegroundColor
                            font.family: Config.ui.fontFamily
                            font.pixelSize: Config.quickSettings.bodyFontSize
                            elide: Text.ElideRight
                        }

                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        MenuIconButton {
                            glyph: root.inputSource ? "󰍬" : "󰕾"
                            actionName: deviceRow.audio && deviceRow.audio.muted
                                ? "Unmute " + (root.inputSource ? "audio input" : "audio output")
                                : "Mute " + (root.inputSource ? "audio input" : "audio output")
                            marked: !deviceRow.audio || deviceRow.audio.muted
                            theme: deviceRow.resolvedTheme
                            borderless: !deviceRow.isDefault
                            visualState: !deviceRow.audio || deviceRow.audio.muted
                                ? Config.states.disabled
                                : Config.states.defaultState
                            enabled: deviceRow.audio !== null
                            onClicked: deviceRow.audio.muted = !deviceRow.audio.muted
                        }

                        VolumeSlider {
                            Layout.fillWidth: true
                            audio: deviceRow.audio
                            theme: deviceRow.resolvedTheme
                            surfaceHovered: deviceRow.hovered
                            visualState: !deviceRow.audio || deviceRow.audio.muted
                                ? Config.states.disabled
                                : deviceRow.isDefault ? Config.states.active : Config.states.defaultState
                        }

                        Text {
                            Layout.preferredWidth: 34
                            text: deviceRow.audio
                                ? Math.round(deviceRow.audio.volume * 100) + "%"
                                : "—"
                            color: deviceRow.resolvedSecondaryColor
                            font.family: Config.ui.fontFamily
                            font.pixelSize: Config.quickSettings.smallFontSize
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                width: parent.width - 16
                text: Pipewire.ready
                    ? (root.inputSource ? "No input devices found" : "No output devices found")
                    : "Waiting for PipeWire…"
                color: Config.colors.overlay1
                font.family: Config.ui.fontFamily
                font.pixelSize: Config.quickSettings.bodyFontSize
                horizontalAlignment: Text.AlignHCenter
                visible: root.nodes.length === 0
            }
        }
    }
}
