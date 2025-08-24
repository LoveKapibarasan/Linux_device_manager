const { app, BrowserWindow, globalShortcut, session } = require("electron");
const path = require("path");

let win;

function createWindow() {
  win = new BrowserWindow({
    fullscreen: true,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      partition: "persist:default"
    }
  });

  win.loadURL("about:blank");

  win.webContents.setWindowOpenHandler(({ url }) => {
  win.loadURL(url); // 現在のウィンドウに読み込み直す
  return { action: "deny" }; // 新しいタブ・ウィンドウは禁止
  });


  // ダウンロード処理
  session.defaultSession.on("will-download", (event, item) => {
    const savePath = path.join(app.getPath("downloads"), item.getFilename());
    item.setSavePath(savePath);

    item.once("done", (_e, state) => {
      console.log(state === "completed" ? `ダウンロード完了: ${savePath}` : `失敗: ${state}`);
    });
  });

  // Ctrl+Alt+U で google.com を開く
  globalShortcut.register("Control+Alt+U", () => {
    win.loadURL("https://www.google.com/");
  });
}

app.whenReady().then(() => {
  createWindow();
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
