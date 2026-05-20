{{flutter_js}}
{{flutter_build_config}}

// CanvasKit supports BackdropFilter blur; skwasm (default on recent Flutter)
// does not — required for liquid-glass drawer / bottom sheets on web.
_flutter.loader.load({
  config: {
    renderer: "canvaskit",
  },
});
