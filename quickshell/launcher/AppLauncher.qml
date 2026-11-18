import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

import "../components"
import "../config.js" as Config

Scope {
    id: root
    readonly property string font: Config.launcher.fontFamily

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            launcherPrompt.visible = !launcherPrompt.visible
            if (launcherPrompt.visible) {
                searchInput.text = ""
                selectedIndex = -1
                searchInput.forceActiveFocus()
            }
        }
    }

    property int selectedIndex: 0

    ScriptModel {
        id: filteredApps
        objectProp: "id"
        values: {
            const all = [...DesktopEntries.applications.values];
            const q = searchInput.text.trim().toLowerCase();
            if (q === "") return all.sort((a, b) => a.name.localeCompare(b.name));
            return all.filter(d =>
                (d.name && d.name.toLowerCase().includes(q)) ||
                (d.genericName && d.genericName.toLowerCase().includes(q)) ||
                (d.keywords && d.keywords.some(k => k.toLowerCase().includes(q))) ||
                (d.categories && d.categories.some(c => c.toLowerCase().includes(q)))
            ).sort((a, b) => {
                    const an = a.name.toLowerCase();
                    const bn = b.name.toLowerCase();
                    const aStarts = an.startsWith(q);
                    const bStarts = bn.startsWith(q);
                    if (aStarts && !bStarts) return -1;
                    if (!aStarts && bStarts) return 1;
                    return an.localeCompare(bn);
            });
        }
    }

    function launchApp(entry) {
        entry.execute();
        launcherPrompt.visible = false;
    }

    Prompt {
        id: launcherPrompt

        visible: false
        layerNamespace: "quickshell-launcher"
        cardWidth: Config.launcher.width
        cardHeight: Config.launcher.height
        cardBackground: Config.launcher.background
        dismissOnBackdropClick: true
        backdropColor: "transparent"
        onDismissed: launcherPrompt.visible = false

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Config.launcher.padding
            spacing: Config.launcher.spacing

            ThemedRectangle {
                Layout.fillWidth: true
                height: Config.launcher.searchHeight
                defaultBackgroundColor: Config.launcher.background
                highlighted: searchInput.activeFocus

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Config.launcher.searchPadding
                    anchors.rightMargin: Config.launcher.searchPadding
                    spacing: Config.launcher.searchSpacing

                    Text {
                        text: ""
                        color: Config.colors.overlay1
                        font.pixelSize: Config.launcher.searchIconFontSize
                        font.family: root.font
                        Layout.alignment: Qt.AlignVCenter
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        color: Config.colors.text
                        font.pixelSize: Config.launcher.searchFontSize
                        font.family: root.font
                        clip: true
                        focus: true
                        Accessible.role: Accessible.EditableText
                        Accessible.name: "Search applications"

                        Text {
                            anchors.fill: parent
                            text: "Type to search..."
                            color: Config.colors.overlay1
                            font: parent.font
                            visible: !parent.text
                            verticalAlignment: Text.AlignVCenter
                        }

                        onTextChanged: root.selectedIndex = text === "" ? -1 : 0

                        Keys.onEscapePressed: launcherPrompt.visible = false

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Down) {
                                event.accepted = true;
                                root.selectedIndex = Math.min(root.selectedIndex + 1, resultsList.count - 1);
                                resultsList.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                            } else if (event.key === Qt.Key_Up) {
                                event.accepted = true;
                                root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
                                resultsList.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                event.accepted = true;
                                if (root.selectedIndex >= 0) {
                                    const entry = filteredApps.values[root.selectedIndex];
                                    if (entry) root.launchApp(entry);
                                }
                            } else if (event.key === Qt.Key_Tab) {
                                event.accepted = true;
                                root.selectedIndex = Math.min(root.selectedIndex + 1, resultsList.count - 1);
                                resultsList.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                            }
                        }
                    }
                }
            }

            Text {
                text: resultsList.count + " application" + (resultsList.count !== 1 ? "s" : "")
                color: Config.colors.overlay1
                font.pixelSize: Config.launcher.countFontSize
                font.family: root.font
            }

            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: filteredApps
                clip: true
                spacing: Config.launcher.listSpacing

                delegate: ThemedRectangle {
                    id: delegateRoot
                    required property var modelData
                    required property int index

                    Accessible.role: Accessible.Button
                    Accessible.name: (modelData.name ?? "Application") + (modelData.genericName ? " - " + modelData.genericName : "")

                    width: resultsList.width
                    height: Config.launcher.itemHeight
                    visualState: root.selectedIndex === delegateRoot.index
                        ? Config.states.active
                        : Config.states.default
                    trackHover: true
                    borderless: true
                    defaultBackgroundColor: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Config.launcher.itemPadding
                        anchors.rightMargin: Config.launcher.itemPadding
                        spacing: Config.launcher.itemSpacing

                        Item {
                            width: Config.launcher.iconSize
                            height: Config.launcher.iconSize
                            Layout.alignment: Qt.AlignVCenter

                            IconImage {
                                anchors.fill: parent
                                source: Quickshell.iconPath(delegateRoot.modelData.icon ?? "", true)
                                visible: (delegateRoot.modelData.icon ?? "") !== ""
                            }

                            Text {
                                anchors.centerIn: parent
                                text: (delegateRoot.modelData.name || "?").charAt(0).toUpperCase()
                                color: delegateRoot.resolvedForegroundColor
                                font.pixelSize: Config.launcher.iconFallbackFontSize
                                font.family: root.font
                                visible: (delegateRoot.modelData.icon ?? "") === ""
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Config.launcher.itemInfoSpacing

                            Text {
                                text: delegateRoot.modelData.name ?? ""
                                color: delegateRoot.resolvedForegroundColor
                                font.pixelSize: Config.launcher.itemFontSize
                                font.family: root.font
                                font.bold: root.selectedIndex === delegateRoot.index
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: delegateRoot.modelData.genericName ?? delegateRoot.modelData.comment ?? ""
                                color: delegateRoot.resolvedSecondaryColor
                                font.pixelSize: Config.launcher.itemSubtitleFontSize
                                font.family: root.font
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                visible: text !== ""
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.launchApp(delegateRoot.modelData)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "  No applications found"
                    color: Config.colors.overlay1
                    font.pixelSize: Config.launcher.emptyFontSize
                    font.family: root.font
                    visible: resultsList.count === 0 && searchInput.text !== ""
                }
            }
        }
    }
}
