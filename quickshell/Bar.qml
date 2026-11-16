import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import "config.js" as Config

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }
    color: "transparent"

    implicitHeight: Config.bar.height

    BackgroundEffect.blurRegion: Region {
        id: barBlurRegion

        Component.onCompleted: {
            Qt.callLater(() => {
                const visit = item => {
                    for (let i = 0; i < item.children.length; i++) {
                        const child = item.children[i];
                        if (child.blurRegion) barBlurRegion.regions.push(child.blurRegion);
                        visit(child);
                    }
                };
                visit(contentItem);
            });
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: Config.bar.margin

        RowLayout {
            id: leftItems
            anchors.left: parent.left

            BarItem {
                implicitWidth: Config.bar.height - Config.bar.margin

                Image {
                    id: icon
                    anchors.centerIn: parent
                    source: "./nix.svg"
                    width: Config.bar.height
                    height: Config.bar.height
                }
            }
        }

        RowLayout {
            id: centerItems
            anchors.centerIn: parent

            Repeater {
                model: 10

                BarItem {
                    implicitWidth: Config.bar.height - Config.bar.margin

                    property var workspace: Hyprland.workspaces.values.find(w => w.id == index + 1)
                    property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

                    active: isActive
                    disabled: !workspace

                    Text {
                        anchors.centerIn: parent
                        text: index + 1
                        color: workspace ? Config.colors.text : Config.colors.subtext0
                        font.family: Config.bar.fontFamily
                        font.pixelSize: Config.bar.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (index + 1) + " })")
                    }
                }
            }
        }

        RowLayout {
            id: rightItems
            anchors.right: parent.right

            BarItem {
                implicitWidth: time.width + 12

                Text {
                    id: time
                    color: Config.colors.text
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize

                    anchors.centerIn: parent

                    Process {
                        id: timeProc
                        command: ["date", "+%I:%M %p"]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: time.text = text.trim();
                        }
                    }

                    Timer {
                        interval: 200
                        running: true
                        repeat: true
                        onTriggered: timeProc.running = true
                    }
                }
            }

            BarItem {
                implicitWidth: date.width + 12

                Text {
                    id: date
                    color: Config.colors.text
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize

                    anchors.centerIn: parent

                    Process {
                        id: dateProc
                        command: ["date", "+%b %d, %Y"]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: date.text = text.trim();
                        }
                    }

                    Timer {
                        interval: 200
                        running: true
                        repeat: true
                        onTriggered: dateProc.running = true
                    }
                }
            }
        }
    }
}
