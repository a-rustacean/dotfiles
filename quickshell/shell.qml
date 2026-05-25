import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    // Theme colors
    property color colBg: "#00000000"
    property color colFg: "#ffffff"
    property color colGray: "#c0c0c0"
    property color colMuted: "#444b6a"

    // Font
    property string fontFamily: "JetBrainsMono Nerd Font Mono"
    property int fontSize: 15

    // System info properties
    property string activeWindow: "NixOS"

    // CPU tracking
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    // Active window title
    Process {
        id: windowProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.class // \"NixOS\"'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    if (data == "NixOS" || !data.includes("-")) {
                        activeWindow = data.trim()
                    } else {
                        activeWindow = data
                            .trim()
                            .split("-")
                            .map((part) => part[0].toUpperCase() + part.slice(1).toLowerCase())
                            .join(" ")
                    }
                }
            }
        }
        Component.onCompleted: running = true
    }

    // Event-based updates for window (instant)
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            windowProc.running = true
        }
    }

    // Backup timer for window (catches edge cases)
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            windowProc.running = true
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30
            color: root.colBg

            margins {
                top: 0
                bottom: 0
                left: 0
                right: 0
            }

            Rectangle {
                anchors.fill: parent
                color: root.colBg

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item { width: 8 }

                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        color: "transparent"

                        Text {
                            text: ""
                            color: "#ffffff"
                            font.pixelSize: 17
                            anchors.centerIn: parent
                        }
                    }

                    Text {
                        text: activeWindow
                        color: root.colFg
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Repeater {
                        model: 10

                        Rectangle {
                            Layout.preferredWidth: index === 9 ? 30 : 20
                            Layout.preferredHeight: parent.height
                            color: "transparent"

                            property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
                            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                            property bool hasWindows: workspace !== null

                            Text {
                                text: index + 1
                                color: parent.isActive ? root.colFg : (parent.hasWindows ? root.colGray : root.colMuted)
                                font.pixelSize: root.fontSize
                                font.family: root.fontFamily
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            Rectangle {
                                width: 20
                                height: 3
                                color: parent.isActive ? root.colFg : root.colBg
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: workspace?.activate()
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 2
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        id: clockText
                        text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                        color: root.colFg
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd MMM dd hh:mm A")
                        }
                    }

                    Item { width: 8 }
                }
            }
        }
    }
}

