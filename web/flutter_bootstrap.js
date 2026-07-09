{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    
    // Remove the HTML loader immediately when the engine is initialized and ready to run the app
    const loadingDiv = document.querySelector('.loading-container');
    if (loadingDiv) {
      loadingDiv.remove();
    }
    
    await appRunner.runApp();
  }
});
