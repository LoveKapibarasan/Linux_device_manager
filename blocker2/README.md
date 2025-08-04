
### Log Monitoring


本アプリの動作ログは root のホームディレクトリに出力されます。

- ログファイル: `/root/.shutdown_cui.log`


#### リアルタイム監視

```bash
sudo tail -f /root/.shutdown_cui.log
```


#### サービスの状態確認

```bash
systemctl status shutdown-cui.service
```


*** End Patch

```bash
sudo apt install libnotify-bin
```