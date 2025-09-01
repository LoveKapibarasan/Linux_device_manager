const { app, BrowserWindow, globalShortcut, session } = require("electron");
const path = require("path");

let win;

function createWindow() {
  win = new BrowserWindow({
    fullscreen: true,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      webviewTag: true,
      partition: "persist:default"
    }
  });

  win.loadURL("about:blank");

  // Replace "open new window" → reload in current window
  win.webContents.setWindowOpenHandler(({ url }) => {
    win.loadURL(url); // Reload in the current window
    return { action: "deny" }; // Disable new tabs/windows
  });

  // Download handling
  session.defaultSession.on("will-download", (event, item) => {
    const savePath = path.join(app.getPath("downloads"), item.getFilename());
    item.setSavePath(savePath);

    item.once("done", (_e, state) => {
      console.log(state === "completed"
        ? `Download completed: ${savePath}`
        : `Download failed: ${state}`);
    });
  });

  // Ctrl+Alt+U → Googleにリダイレクト
  globalShortcut.register("Control+Alt+U", () => {
    win.loadURL("https://www.google.com");
  });
}

app.whenReady().then(() => {
  createWindow();
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});

