# jxa_reminder launchd 運用手順

このドキュメントは、`ReCreateReminderItems2.jxa` を 1 時間に 1 回 `launchd` で実行するための設定手順です。

## 前提

- 対象スクリプト: `/Users/hide/Documents/Development/jxa_reminder/ReCreateReminderItems2.jxa`
- plist ファイル: `/Users/hide/Documents/Development/jxa_reminder/com.hide.jxa-reminder.plist`
- 実行ユーザー: ログイン中のユーザー（LaunchAgent）

## 1. plist を配置する

```bash
mkdir -p ~/Library/LaunchAgents
cp /Users/hide/Documents/Development/jxa_reminder/com.hide.jxa-reminder.plist ~/Library/LaunchAgents/
```

## 2. plist の構文を確認する

```bash
plutil -lint ~/Library/LaunchAgents/com.hide.jxa-reminder.plist
```

`OK` と表示されれば問題ありません。

## 3. LaunchAgent を有効化する

```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.hide.jxa-reminder.plist
```

すでに同じラベルがロード済みでエラーになる場合は、いったん解除してから再実行します。

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.hide.jxa-reminder.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.hide.jxa-reminder.plist
```

## 4. 即時実行して動作確認する

```bash
launchctl kickstart -k gui/$(id -u)/com.hide.jxa-reminder
```

## 5. 状態確認

```bash
launchctl print gui/$(id -u)/com.hide.jxa-reminder
```

`state = running` や `last exit code = 0` を確認します。

## 6. ログ確認

plist では次のログに出力されます。

- 標準出力: `/tmp/jxa-reminder.out.log`
- 標準エラー: `/tmp/jxa-reminder.err.log`

確認コマンド:

```bash
tail -n 100 /tmp/jxa-reminder.out.log
tail -n 100 /tmp/jxa-reminder.err.log
```

## 7. 停止・無効化

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.hide.jxa-reminder.plist
```

## 8. 設定変更後の反映

plist を編集したら、次の順で反映します。

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.hide.jxa-reminder.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.hide.jxa-reminder.plist
```

## 補足

- `StartInterval` は実行間隔（秒）です。現在の設定では `3600` 秒（1時間）です。
- スリープ中は予定時刻どおりに実行されないことがあります。
- リマインダーへのアクセス権限ダイアログが出る場合は許可してください。
