import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import "../components"
import "../config.js" as Config

PanelWindow {
    id: root

    WlrLayershell.namespace: "quickshell"

    anchors {
        top: true
        left: true
        right: true
    }
    color: "transparent"

    implicitHeight: Config.bar.height
    property date currentDateTime: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentDateTime = new Date()
    }

    BackgroundEffect.blurRegion: Region {
        id: barBlurRegion

        Component.onCompleted: {
            Qt.callLater(() => {
                    const visit = item => {
                        for (let i = 0; i < item.children.length; i++) {
                            const child = item.children[i];
                            if (child.blurRegion && child.blurRegionEnabled !== false)
                                barBlurRegion.regions.push(child.blurRegion);
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
                    anchors.centerIn: parent
                    source: "../nix.svg"
                    width: Config.bar.height
                    height: Config.bar.height
                }
            }

            BarItem {
                implicitWidth: title.width + 12

                Text {
                    id: title
                    width: Math.min(title.implicitWidth, Config.bar.titleMaxWidth)
                    elide: Text.ElideRight
                    anchors.centerIn: parent
                    text: {
                        const active = ToplevelManager.activeToplevel;
                        if (!active)
                            return "Desktop";

                        return DesktopEntries.heuristicLookup(active.appId)?.name
                            || active.appId
                            || "Unknown application";
                    }
                    color: Config.colors.text
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize
                }
            }

            NowPlaying {}
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

                    visualState: isActive
                        ? Config.states.active
                        : workspace ? Config.states.default : Config.states.dimmed

                    Text {
                        anchors.centerIn: parent
                        text: index + 1
                        color: parent.resolvedForegroundColor
                        font.family: Config.bar.fontFamily
                        font.pixelSize: Config.bar.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (index + 1) + " })")
                    }
                }
            }
        }

        RowLayout {
            id: rightItems
            anchors.right: parent.right

            QuickSettings {}

            BarItem {
                implicitWidth: time.width + 12

                Text {
                    id: time
                    color: Config.colors.text
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize

                    anchors.centerIn: parent
                    text: Qt.formatDateTime(root.currentDateTime, "hh:mm AP")
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
                    text: Qt.formatDateTime(root.currentDateTime, "MMM dd, yyyy")
                }
            }
        }
    }
}
