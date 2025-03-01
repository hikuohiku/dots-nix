final: prev: {
  microsoft-edge-dev = prev.microsoft-edge-dev.override {
    commandLineArgs = "--enable-features=TouchpadOverscrollHistoryNavigation --enable-wayland-ime";
  };
}
