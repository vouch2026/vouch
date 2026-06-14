{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    
    await appRunner.runApp();
    
    // Once the app is running, fade out the splash screen and remove it
    const splash = document.getElementById('splash-container');
    if (splash) {
      splash.style.opacity = '0';
      setTimeout(() => {
        splash.remove();
      }, 400); // Matches the 0.4s transition defined in CSS
    }
  }
});
