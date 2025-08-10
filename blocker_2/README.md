

### 注意


本アプリはrootサービスとして動作します。
- デスクトップ通知（notify-send）は環境によっては表示されず、DBUS関連のエラーがログに出る場合があります（これは無視して構いません）。
- ただし「シャットダウン失敗」エラーが出る場合は、制限機能が正しく動作していません。polkit設定や実行環境（仮想環境の制限など）を必ず見直してください。

---

### Log Monitoring


本アプリの動作ログは root のホームディレクトリに出力されます。

- ログファイル: `/root/.shutdown_cui.log`


#### リアルタイム監視

```bash
sudo tail -f /root/.shutdown_cui.log
```



#### サービスの一時停止・無効化・再有効化

一時的にブロッカーを止めたい場合:

```bash
sudo systemctl stop shutdown-cui.service
```

自動起動も止めたい場合:

```bash
sudo systemctl disable shutdown-cui.service
```

再度有効化・起動したい場合:

```bash
sudo systemctl enable --now shutdown-cui.service
```

---

#### サービスの状態確認

```bash
systemctl status shutdown-cui.service
```


*** End Patch

```bash
sudo apt install libnotify-bin
```