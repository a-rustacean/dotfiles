// Catppuccin Mocha
const colors = {
  rosewater: "#f5e0dc",
  flamingo: "#f2cdcd",
  pink: "#f5c2e7",
  mauve: "#cba6f7",
  red: "#f38ba8",
  maroon: "#eba0ac",
  peach: "#fab387",
  yellow: "#f9e2af",
  green: "#a6e3a1",
  teal: "#94e2d5",
  sky: "#89dceb",
  sapphire: "#74c7ec",
  blue: "#89b4fa",
  lavender: "#b4befe",

  text: "#cdd6f4",
  subtext1: "#bac2de",
  subtext0: "#a6adc8",
  overlay2: "#9399b2",
  overlay1: "#7f849c",
  overlay0: "#6c7086",
  surface2: "#585b70",
  surface1: "#45475a",
  surface0: "#313244",
  base: "#1e1e2e",
  mantle: "#181825",
  crust: "#11111b",
};

// Convert "#RRGGBB" to "#AARRGGBB" with the given opacity (0.0 - 1.0).
function withAlpha(hex, alpha) {
  const a = Math.round(alpha * 255).toString(16).padStart(2, "0");
  return "#" + a + hex.slice(1);
}

const ui = {
  fontFamily: "JetBrainsMono Nerd Font",
  rounding: 4,
  borderWidth: 2,
  animationDuration: 185,
  // 0 = fully transparent, 1 = opaque.
  backgroundOpacity: 0.55,
  selectedBackground: colors.text,
  selectedForeground: colors.base,
  selectedSecondary: colors.surface0,
};

const bar = {
  fontFamily: ui.fontFamily,
  fontSize: 16,
  height: 35,
  margin: 6,
  titleMaxWidth: 300,
  nowPlayingWidth: 220,
  nowPlayingIconSize: 14,
  nowPlayingSpacing: 8,
  nowPlayingScrollSpeed: 40,
  nowPlayingScrollGap: 20,
  nowPlayingMarkerSize: 4,
  background: withAlpha(colors.base, ui.backgroundOpacity),
  disabledBackground: withAlpha(colors.surface0, ui.backgroundOpacity),
};

const launcher = {
  fontFamily: ui.fontFamily,

  background: withAlpha(colors.base, ui.backgroundOpacity),

  width: 580,
  height: 480,
  padding: 16,
  spacing: 12,

  searchHeight: 44,
  searchPadding: 14,
  searchSpacing: 10,
  searchFontSize: 15,
  searchIconFontSize: 16,

  countFontSize: 11,

  listSpacing: 2,
  itemHeight: 44,
  itemPadding: 12,
  itemSpacing: 12,
  itemInfoSpacing: 1,
  itemFontSize: 13,
  itemSubtitleFontSize: 11,
  iconSize: 28,
  iconFallbackFontSize: 20,

  emptyFontSize: 14,
};

const quickSettings = {
  menuWidth: 340,
  menuHeight: 480,
  menuGap: 8,
  screenMargin: 12,
  menuPadding: 12,
  menuSpacing: 8,
  sectionSpacing: 10,
  rowHeight: 60,
  audioRowInset: 6,
  buttonHeight: 28,
  titleFontSize: 14,
  bodyFontSize: 12,
  smallFontSize: 10,
  iconFontSize: 16,
  sliderWidth: 112,
};
