{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
    // Flutter 3.50+ 全面解锁 Safari (WebKit 26.2+) 与 Firefox (Gecko 147+) 的 Wasm 支持
    wasmAllowList: {
      blink: true,
      webkit: true,
      gecko: true,
    },
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    
    // 平滑淡出并移除 HTML 骨架屏与首屏进度条，避免闪烁
    const loadingDiv = document.querySelector('.loading-container');
    if (loadingDiv) {
      loadingDiv.style.opacity = '0';
      loadingDiv.style.transition = 'opacity 0.25s ease-out';
      setTimeout(() => {
        if (loadingDiv.parentNode) loadingDiv.parentNode.removeChild(loadingDiv);
      }, 250);
    }
    const topLoader = document.getElementById('top-loader');
    if (topLoader) {
      topLoader.style.opacity = '0';
      topLoader.style.transition = 'opacity 0.25s ease-out';
      setTimeout(() => {
        if (topLoader.parentNode) topLoader.parentNode.removeChild(topLoader);
      }, 250);
    }
    
    await appRunner.runApp();
  }
});
