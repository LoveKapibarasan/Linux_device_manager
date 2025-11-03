// https://www.electronjs.org/ja/docs/latest/api/browser-window
const { app, BrowserWindow, ipcMain } = require("electron");
const path = require("path");



app.on('window-all-closed', function () {
        app.quit();
});
app.on('ready', function () {
    const win = new BrowserWindow({
        width: 1000,
        height: 600,
	frame: false,
    });
    win.loadURL('https://shogiwars.heroz.jp/static/webgl/'); // loadUrl() was renamed to loadURL() a while back.
    win.on('closed', function () {
        win = null;
    });



// https://www.electronjs.org/ja/docs/latest/api/cookies
const { session } = require('electron')

// すべてのクッキーをクエリーします。
session.defaultSession.cookies.get({})
  .then((cookies) => {
    console.log(cookies)
  }).catch((error) => {
    console.log(error)
  })

// 特定のurlに関連した全てのクッキーを問い合わせ
session.defaultSession.cookies.get({ url: 'https://shogiwars.heroz.jp/static/webgl/' })
  .then((cookies) => {
    console.log(cookies)
  }).catch((error) => {
    console.log(error)
  })


});
