const { app, BrowserWindow, ipcMain } = require("electron");
const path = require("path");

let mainWindow;
let views = [];   // タブごとの BrowserView を保持
let currentIndex = 0;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
    },
  });

  mainWindow.loadFile("index.html");

  // 最初のタブを作成
  createTab("https://google.com");
}

function createTab(url) {
  const { BrowserView } = require("electron");
  const view = new BrowserView();
  views.push(view);

  mainWindow.setBrowserView(view);
  view.setBounds({ x: 0, y: 60, width: 1200, height: 740 }); // 上部60pxをUI用に確保
  view.setAutoResize({ width: true, height: true });
  view.webContents.loadURL(url);

  currentIndex = views.length - 1;
  updateURL();
}

function switchTab(index) {
  if (views[index]) {
    mainWindow.setBrowserView(views[index]);
    views[index].setBounds({ x: 0, y: 60, width: 1200, height: 740 });
    views[index].setAutoResize({ width: true, height: true });
    currentIndex = index;
    updateURL();
  }
}

function updateURL() {
  const url = views[currentIndex].webContents.getURL();
  mainWindow.webContents.send("update-url", { url, index: currentIndex });
}

// IPC: レンダラーからの操作
ipcMain.on("navigate", (_, url) => {
  views[currentIndex].webContents.loadURL(url);
});
ipcMain.on("back", () => {
  if (views[currentIndex].webContents.canGoBack()) {
    views[currentIndex].webContents.goBack();
  }
});
ipcMain.on("forward", () => {
  if (views[currentIndex].webContents.canGoForward()) {
    views[currentIndex].webContents.goForward();
  }
});
ipcMain.on("new-tab", (_, url) => {
  createTab(url || "https://google.com");
});
ipcMain.on("switch-tab", (_, index) => {
  switchTab(index);
});

app.whenReady().then(createWindow);
