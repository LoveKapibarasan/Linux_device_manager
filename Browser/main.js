// 例: GitHubを開く
// electron app.js https://github.com

// 例: 引数なしの場合は about:blank を開く
// electron app.js



const { app, BrowserWindow, globalShortcut, session } = require("electron");
const path = require("path");

let win;

function createWindow(urlToLoad) {
  win = new BrowserWindow({
    fullscreen: true,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      webviewTag: true,
      partition: "persist:default",
    },
  });

  win.loadURL(urlToLoad || "about:blank");

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
      console.log(
        state === "completed"
          ? `Download completed: ${savePath}`
          : `Download failed: ${state}`
      );
    });
  });

  // Ctrl+Alt+U → Googleにリダイレクト
  globalShortcut.register("Control+Alt+U", () => {
    win.loadURL("https://www.google.com");
  });
}

app.whenReady().then(() => {
  // node ./app.js https://example.com
  const args = process.argv.slice(2);
  const targetURL = args[0];
  createWindow(targetURL);
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});

