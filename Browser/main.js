const { app, BrowserWindow, globalShortcut, dialog, shell, session } = require("electron");
const path = require("path");


// Link: https://ics.media/entry/7298/
let win;

function createWindow() {
  win = new BrowserWindow({
    fullscreen: true,   
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      partition: "persist:default" // Cookie / LocalStorage / Session 保存
    }
  });

  // 起動時は空ページ
  win.loadURL("about:blank");

  // 複数タブ禁止
  win.webContents.setWindowOpenHandler(() => {
    return { action: "deny" };
  });

  // ダウンロードリンク処理
  session.defaultSession.on("will-download", (event, item) => {
    // 保存先のパスを指定（ユーザーの Downloads フォルダ）
    const savePath = path.join(app.getPath("downloads"), item.getFilename());
    item.setSavePath(savePath);

    // 進捗ログ
    item.on("updated", (e, state) => {
      if (state === "progressing") {
        if (item.isPaused()) {
          console.log("ダウンロード一時停止");
        } else {
          console.log(`進捗: ${item.getReceivedBytes()}/${item.getTotalBytes()}`);
        }
      }
    });

    // 完了時
    item.once("done", (e, state) => {
      if (state === "completed") {
        console.log("ダウンロード完了:", savePath);
      } else {
        console.log("ダウンロード失敗:", state);
      }
    });
  });

  // Ctrl+Alt+U で URL 入力ダイアログを表示
  globalShortcut.register("Control+Alt+U", async () => {
    const { response, text } = await dialog.showMessageBox(win, {
      type: "none",
      buttons: ["Open", "Cancel"],
      title: "Open URL",
      message: "URL",
      input: true // Electron v31+ の input サポート
    });

    if (response === 0 && text) {
      let url = text.trim();
      if (!/^https?:\/\//i.test(url)) {
        url = "https://" + url;
      }
      win.loadURL(url);
    }
  });
}

app.whenReady().then(() => {
  createWindow();
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
