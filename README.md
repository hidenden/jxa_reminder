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

## ItemStock のコメント(body)フォーマット

`ItemStock` リスト内の各リマインダーでは、コメント(body)に次の形式を指定できます。

```text
日数[,登録先リマインダー名]
```

- `日数` は必須です。解釈は `parseInt(..., 10)` 相当です。
- `,登録先リマインダー名` は省略可能です。
- コンマ前後の空白文字は許容します。
- コンマが複数含まれる場合は、最初のコンマより後ろ全体を登録先リマインダー名として扱います。
- 登録先リマインダー名を省略した場合は、既定の `定期的な家事` に登録します。

### 例

- `3`
- `5, 定期的な家事`
- `7 , 買い物`
- `10, プロジェクトA, 追加分` （登録先名は `プロジェクトA, 追加分` として扱われます）

### フォーマット不正時の挙動

- 日数が解釈できない場合は、ログにエラーメッセージを出力します。
- 不正なエントリはスキップされ、他のエントリ処理は継続されます。
