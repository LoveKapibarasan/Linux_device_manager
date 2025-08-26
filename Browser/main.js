const { app, BrowserWindow, globalShortcut, session } = require("electron");
const path = require("path");

let win;

// Minimal inline HTML for address bar UI
const simpleHTML = `
<!DOCTYPE html>
<html>
<body style="margin:0;display:flex;flex-direction:column;height:100%;">
  <div style="background:#eee;padding:4px;display:flex;">
    <input id="url" style="flex:1;" placeholder="https://example.com">
    <button id="go">Go</button>
  </div>
  <webview id="view" style="flex:1;"></webview>
  <script>
    const v=document.getElementById("view"),u=document.getElementById("url");
    function nav(){
      let x=u.value.trim();
      if(!/^https?:/i.test(x)) x="https://"+x;
      v.src=x;
    }
    document.getElementById("go").onclick=nav;
    u.addEventListener("keydown",e=>{if(e.key==="Enter")nav();});
  </script>
</body>
</html>
`;

function createWindow() {
  win = new BrowserWindow({
    fullscreen: true,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      webviewTag: true,            // Required for <webview>
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

  // Ctrl+Alt+U → Show address bar UI
  globalShortcut.register("Control+Alt+U", () => {
    win.loadURL("data:text/html;charset=UTF-8," + encodeURIComponent(simpleHTML));
  });
}

app.whenReady().then(() => {
  createWindow();
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
