
### Log Monitoring

本アプリの動作ログは各ユーザーのホームディレクトリに出力されます。

- ログファイル: `~/.shutdown_cui.log`

#### リアルタイム監視

```bash
tail -f ~/.shutdown_cui.log
```

#### すべてのユーザーのログをまとめて監視（rootで）

```bash
tail -f /home/*/.shutdown_cui.log
```

#### サービスの状態確認

```bash
systemctl status shutdown-cui-$(whoami).service
```





```bash
sudo apt install libnotify-bin
```