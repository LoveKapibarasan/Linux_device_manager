const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("electronAPI", {
  navigate: (url) => ipcRenderer.send("navigate", url),
  back: () => ipcRenderer.send("back"),
  forward: () => ipcRenderer.send("forward"),
  newTab: (url) => ipcRenderer.send("new-tab", url),
  switchTab: (index) => ipcRenderer.send("switch-tab", index),
  onUpdateURL: (callback) => ipcRenderer.on("update-url", (_, data) => callback(data)),
});
