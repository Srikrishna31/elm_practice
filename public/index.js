(() => {
  const node = document.getElementById("app");
  const isVisible = () => document.visibilityState === "visible";

  const app = Elm.Main.init({
    node,
    flags: {
      initiallyVisible: isVisible(),
      refreshIntervalMs: 5000
    }
  });

  const reportVisibility = () => {
    app.ports.visibilityChanged.send(isVisible());
  };

  document.addEventListener("visibilitychange", reportVisibility);

  // Synchronize again after installing the listener, closing the small gap
  // between reading the initial flag and subscribing to browser events.
  reportVisibility();

  const dispose = () => {
    document.removeEventListener("visibilitychange", reportVisibility);
    app.ports.visibilityChanged.send(false);
  };

  window.addEventListener("pagehide", dispose, { once: true });
  window.disposeElmPracticeApp = dispose;
})();
