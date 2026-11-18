pragma Singleton

import Quickshell
import QtQuick

// Catppuccin Mocha
Singleton {
    id: root

    readonly property QtObject colors: QtObject {
        readonly property color rosewater: "#f5e0dc"
        readonly property color flamingo: "#f2cdcd"
        readonly property color pink: "#f5c2e7"
        readonly property color mauve: "#cba6f7"
        readonly property color red: "#f38ba8"
        readonly property color maroon: "#eba0ac"
        readonly property color peach: "#fab387"
        readonly property color yellow: "#f9e2af"
        readonly property color green: "#a6e3a1"
        readonly property color teal: "#94e2d5"
        readonly property color sky: "#89dceb"
        readonly property color sapphire: "#74c7ec"
        readonly property color blue: "#89b4fa"
        readonly property color lavender: "#b4befe"

        readonly property color text: "#cdd6f4"
        readonly property color subtext1: "#bac2de"
        readonly property color subtext0: "#a6adc8"
        readonly property color overlay2: "#9399b2"
        readonly property color overlay1: "#7f849c"
        readonly property color overlay0: "#6c7086"
        readonly property color surface2: "#585b70"
        readonly property color surface1: "#45475a"
        readonly property color surface0: "#313244"
        readonly property color base: "#1e1e2e"
        readonly property color mantle: "#181825"
        readonly property color crust: "#11111b"
    }

    readonly property QtObject ui: QtObject {
        readonly property string fontFamily: "JetBrainsMono Nerd Font"
        readonly property int rounding: 4
        readonly property int borderWidth: 2
        readonly property int animationDuration: 185
        // 0 = fully transparent, 1 = opaque.
        readonly property real backgroundOpacity: 0.55
        readonly property color activeBackground: root.colors.text
        readonly property color activeForeground: root.colors.base
        readonly property color activeSecondary: root.colors.surface0
    }

    readonly property QtObject states: QtObject {
        // Shared semantic states for surfaces, text, and icons.
        // Disabled deliberately shares dimmed colors and adds a disabled mark.
        readonly property string active: "active"
        readonly property string defaultState: "default"
        readonly property string dimmed: "dimmed"
        readonly property string disabled: "disabled"
    }

    readonly property QtObject themes: QtObject {
        // Ambient surface theme. The palette also returns its rendered theme for children.
        readonly property string light: "light"
        readonly property string dark: "dark"
    }

    // Return the color with the given opacity (0.0 - 1.0).
    function withAlpha(hex: color, alpha: real): color {
        return Qt.rgba(hex.r, hex.g, hex.b, alpha);
    }

    function statePalette(state: string, theme: string, hovered: bool, pressed: bool, defaultBackground: var): var {
        const visualState = state === states.active || state === states.dimmed || state === states.disabled ? state : states.defaultState;
        const environmentTheme = theme === themes.light ? themes.light : themes.dark;
        const lightEnvironment = environmentTheme === themes.light;
        const restingBackground = defaultBackground ?? (lightEnvironment ? colors.subtext1 : withAlpha(colors.base, ui.backgroundOpacity));

        if (lightEnvironment) {
            if (visualState === states.disabled || visualState === states.dimmed) {
                return {
                    background: colors.subtext0,
                    foreground: colors.base,
                    secondary: colors.surface0,
                    tertiary: colors.surface1,
                    disabledMark: visualState === states.disabled,
                    theme: themes.light
                };
            }

            if (visualState === states.active) {
                return {
                    background: pressed ? colors.subtext0 : hovered ? colors.subtext1 : ui.activeBackground,
                    foreground: colors.base,
                    secondary: colors.surface0,
                    tertiary: colors.surface1,
                    disabledMark: false,
                    theme: themes.light
                };
            }

            return {
                background: pressed ? colors.subtext0 : hovered ? colors.text : restingBackground,
                foreground: colors.base,
                secondary: colors.surface0,
                tertiary: colors.surface1,
                disabledMark: false,
                theme: themes.light
            };
        }

        if (visualState === states.disabled || visualState === states.dimmed) {
            return {
                background: withAlpha(colors.surface0, ui.backgroundOpacity),
                foreground: colors.subtext0,
                secondary: colors.overlay1,
                tertiary: colors.overlay0,
                disabledMark: visualState === states.disabled,
                theme: themes.dark
            };
        }

        if (visualState === states.active) {
            if (pressed) {
                return {
                    background: colors.surface1,
                    foreground: colors.text,
                    secondary: colors.subtext1,
                    tertiary: colors.subtext0,
                    disabledMark: false,
                    theme: themes.dark
                };
            }
            if (hovered) {
                return {
                    background: colors.surface0,
                    foreground: colors.text,
                    secondary: colors.subtext1,
                    tertiary: colors.subtext0,
                    disabledMark: false,
                    theme: themes.dark
                };
            }
            return {
                background: ui.activeBackground,
                foreground: ui.activeForeground,
                secondary: ui.activeSecondary,
                tertiary: colors.overlay1,
                disabledMark: false,
                theme: themes.light
            };
        }

        return {
            background: pressed ? colors.surface1 : hovered ? colors.surface0 : restingBackground,
            foreground: colors.text,
            secondary: colors.subtext0,
            tertiary: colors.overlay1,
            disabledMark: false,
            theme: themes.dark
        };
    }

    readonly property QtObject bar: QtObject {
        readonly property string fontFamily: root.ui.fontFamily
        readonly property int fontSize: 16
        readonly property int height: 35
        readonly property int margin: 6
        readonly property int titleMaxWidth: 300
        readonly property int nowPlayingWidth: 220
        readonly property int nowPlayingIconSize: 14
        readonly property int nowPlayingSpacing: 8
        readonly property int nowPlayingScrollSpeed: 40
        readonly property int nowPlayingScrollGap: 20
        readonly property int nowPlayingMarkerSize: 4
        readonly property color background: root.withAlpha(root.colors.base, root.ui.backgroundOpacity)
    }

    readonly property QtObject launcher: QtObject {
        readonly property string fontFamily: root.ui.fontFamily

        readonly property color background: root.withAlpha(root.colors.base, root.ui.backgroundOpacity)

        readonly property int width: 580
        readonly property int height: 480
        readonly property int padding: 16
        readonly property int spacing: 12

        readonly property int searchHeight: 44
        readonly property int searchPadding: 14
        readonly property int searchSpacing: 10
        readonly property int searchFontSize: 15
        readonly property int searchIconFontSize: 16

        readonly property int countFontSize: 11

        readonly property int listSpacing: 2
        readonly property int itemHeight: 44
        readonly property int itemPadding: 12
        readonly property int itemSpacing: 12
        readonly property int itemInfoSpacing: 1
        readonly property int itemFontSize: 13
        readonly property int itemSubtitleFontSize: 11
        readonly property int iconSize: 28
        readonly property int iconFallbackFontSize: 20

        readonly property int emptyFontSize: 14
    }

    readonly property QtObject quickSettings: QtObject {
        readonly property int menuWidth: 340
        readonly property int menuHeight: 480
        readonly property int menuGap: 8
        readonly property int screenMargin: 12
        readonly property int menuPadding: 12
        readonly property int menuSpacing: 8
        readonly property int sectionSpacing: 10
        readonly property int rowHeight: 60
        readonly property int audioRowInset: 6
        readonly property int buttonHeight: 28
        readonly property int titleFontSize: 14
        readonly property int bodyFontSize: 12
        readonly property int smallFontSize: 10
        readonly property int iconFontSize: 16
        readonly property int sliderWidth: 112
    }
}
