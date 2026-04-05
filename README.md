# jxa_reminder deploy 手順

このリポジトリは、開発用 JXA と実行用 JXA を分離して運用します。
`make deploy` を実行すると、次を自動で行います。

1. 実行用 JXA を実行環境ディレクトリへコピー
2. 環境依存パスを埋め込んだ plist を生成
3. `~/Library/LaunchAgents` へ配置
4. `plutil` で構文検証
5. `launchctl` で再ロード
6. `kickstart` して状態を表示

## 前提

- 対象スクリプト: `ReCreateReminderItems2.jxa`
- plist テンプレート: `com.hide.jxa-reminder.plist.template`
- 実行用 JXA 配置先: `~/Library/Application Support/jxa-reminder/`
- LaunchAgent ラベル: `com.hide.jxa-reminder`

## デプロイ

```bash
make deploy
```

### 主な生成・配置先

- 生成 plist: `.build/com.hide.jxa-reminder.plist`
- 配置 plist: `~/Library/LaunchAgents/com.hide.jxa-reminder.plist`
- 実行スクリプト: `~/Library/Application Support/jxa-reminder/ReCreateReminderItems2.jxa`

## 状態確認

```bash
make status
```

## 停止・撤去

```bash
make undeploy
```

## ログ確認

- 標準出力: `/tmp/jxa-reminder.out.log`
- 標準エラー: `/tmp/jxa-reminder.err.log`

```bash
tail -n 100 /tmp/jxa-reminder.out.log
tail -n 100 /tmp/jxa-reminder.err.log
```

## 注意事項

- 初回実行時に Reminders へのアクセス許可ダイアログが出る場合があります。
- `StartInterval` は 3600 秒（1時間）です。
- スリープ中は予定時刻どおりに実行されないことがあります。
- `ItemStock` リストが存在しない場合、スクリプトは処理対象なしで終了します。
