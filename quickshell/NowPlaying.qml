import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import "config.js" as Config

BarItem {
    id: root

    implicitWidth: Math.min(Config.bar.nowPlayingWidth, marqueeRow.implicitWidth + 38)
    visible: player !== null
    active: hovered

    property bool hovered: false

    readonly property var player: {
        const players = Mpris.players.values.filter(p => p.trackTitle.length > 0);

        return players.find(p => p.isPlaying)
        ?? players.find(p => p.playbackState !== MprisPlaybackState.Stopped)
        ?? null;
    }

    readonly property bool paused: player !== null && !player.isPlaying
    readonly property string displayTitle: player
    ? player.trackTitle.replace(/\s+/g, " ").trim()
    : ""

    function togglePlayback() {
        if (!player)
        return;

        if (player.canTogglePlaying) {
            player.togglePlaying();
        } else if (player.isPlaying && player.canPause) {
            player.pause();
        } else if (!player.isPlaying && player.canPlay) {
            player.play();
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        z: 1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onContainsMouseChanged: root.hovered = containsMouse
        onClicked: root.togglePlayback()
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 8
            rightMargin: 8
        }
        spacing: Config.bar.nowPlayingSpacing

        Item {
            id: icon

            Layout.preferredWidth: Config.bar.nowPlayingIconSize
            Layout.preferredHeight: Config.bar.nowPlayingIconSize
            Layout.alignment: Qt.AlignVCenter

            Row {
                id: equalizer

                visible: !root.paused && !root.hovered
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: 3

                    Item {
                        width: 2
                        height: icon.height

                        Rectangle {
                            id: bar

                            width: 2
                            height: 4
                            radius: 1
                            color: Config.colors.text
                            anchors.centerIn: parent

                            SequentialAnimation {
                                running: equalizer.visible && root.visible
                                loops: Animation.Infinite

                                PauseAnimation {
                                    duration: index * 90
                                }

                                NumberAnimation {
                                    target: bar
                                    property: "height"
                                    to: 12
                                    duration: 300 + index * 60
                                    easing.type: Easing.InOutSine
                                }

                                NumberAnimation {
                                    target: bar
                                    property: "height"
                                    to: 4
                                    duration: 300 + index * 70
                                    easing.type: Easing.InOutSine
                                }
                            }
                        }
                    }
                }
            }

            Row {
                id: hoverBars

                visible: !root.paused && root.hovered
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: 2

                    Item {
                        width: 2
                        height: icon.height

                        Rectangle {
                            width: 2
                            height: 10
                            radius: 1
                            color: Config.colors.text
                            anchors.centerIn: parent
                        }
                    }
                }
            }

            Shape {
                id: pauseShape

                width: 10
                height: 12
                anchors.centerIn: parent
                visible: root.paused

                ShapePath {
                    fillColor: Config.colors.text
                    strokeColor: "transparent"

                    startX: 0
                    startY: 0
                    PathLine { x: pauseShape.width; y: pauseShape.height / 2 }
                    PathLine { x: 0; y: pauseShape.height }
                    PathLine { x: 0; y: 0 }
                }
            }
        }

        Item {
            id: viewport

            readonly property real textWidth: firstCopy.implicitWidth
            readonly property real overflow: Math.max(0, textWidth - width)
            readonly property real stepWidth: textWidth + 2 * Config.bar.nowPlayingScrollGap + Config.bar.nowPlayingMarkerSize
            readonly property bool active: root.visible

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            function restartMarquee() {
                marquee.stop();
                marqueeRow.x = 0;

                if (active && overflow > 0)
                marquee.start();
            }

            Component.onCompleted: restartMarquee()
            onActiveChanged: restartMarquee()
            onWidthChanged: restartMarquee()
            onOverflowChanged: restartMarquee()

            Row {
                id: marqueeRow

                anchors.verticalCenter: parent.verticalCenter
                spacing: Config.bar.nowPlayingScrollGap

                Text {
                    id: firstCopy

                    text: root.displayTitle
                    color: Config.colors.text
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize
                    textFormat: Text.PlainText

                    width: implicitWidth
                    onTextChanged: viewport.restartMarquee()
                }

                Item {
                    id: repeatMarker

                    width: Config.bar.nowPlayingMarkerSize
                    height: firstCopy.height
                    visible: viewport.overflow > 0

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: width
                        radius: width / 2
                        color: Config.colors.overlay1
                    }
                }

                Text {
                    visible: viewport.overflow > 0

                    text: root.displayTitle
                    color: Config.colors.text
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize
                    textFormat: Text.PlainText

                    width: implicitWidth
                }
            }

            NumberAnimation {
                id: marquee

                target: marqueeRow
                property: "x"
                from: 0
                to: -viewport.stepWidth
                duration: Math.max(500, viewport.stepWidth / Config.bar.nowPlayingScrollSpeed * 1000)
                loops: Animation.Infinite
                easing.type: Easing.Linear
            }
        }
    }
}
