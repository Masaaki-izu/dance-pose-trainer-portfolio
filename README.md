# dance_pose_trainer

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Androidでの実行手順（日本語）

前提:
- Flutter SDK と Android SDK がインストールされていること
- 実機またはエミュレータが用意されていること

手順:

1. 依存パッケージを取得:

```bash
flutter pub get
```

2. Androidデバイスを接続するかエミュレータを起動する

3. アプリを起動:

```bash
flutter run -d <device-id>
```

注意点:
- 初回起動時にカメラとマイクの権限を求められます。許可してください。
- 録画ファイルはアプリのドキュメントフォルダ（アプリ専用領域）に保存されます。

今後の拡張:
- 録画ファイルからPose Detection（MediaPipeやML Kit）を組み込みやすい構成にしています。

