# BlinkID + BlinkCard iOS build failure (Flutter)

A new Flutter app that depends on `blinkid_flutter` 8000.0.0 and `blinkcard_flutter` 3000.0.0, both from pub.dev, does not compile on iOS.

Only BlinkID and BlinkCard are used. BlinkID Verify is not a dependency anywhere in the app.

## Environment

| | |
|---|---|
| Flutter | 3.47.4 (Dart 3.13.3) |
| Xcode | 27.0 |
| macOS | 26.6.2 |
| iOS integration | Swift Package Manager (`flutter config --enable-swift-package-manager`) |
| blinkid_flutter | 8000.0.0, resolves blinkid-ios 8000.0.0 |
| blinkcard_flutter | 3000.0.0, resolves blinkcard-ios 3000.0.0 (`exact:` pin in its `Package.swift`) |

## Steps to reproduce

```bash
flutter config --enable-swift-package-manager
flutter pub get
flutter build ios --simulator --debug
```

No license keys are needed, because the failure happens at compile time.

## Actual result

```
Swift Compiler Error (Xcode): Cannot convert value of type 'BlinkCard.CameraFrame' to expected argument type 'BlinkID.CameraFrame'
build/ios/SourcePackages/checkouts/blinkcard-ios/Source/BlinkCardUX/ScanningUX/BlinkCardUXModel.swift:24:29
```

blinkcard-ios 3000.0.0 picks the SDK for its shared UX sources with `#if canImport(BlinkIDVerify) / canImport(BlinkID) / canImport(BlinkCard)`. With blinkid-ios in the same build, `canImport(BlinkID)` is true first, so BlinkCardUX is compiled against BlinkID's types.

## Expected result

The app builds with both SDKs, as it did with blinkid_flutter 7.x and blinkcard_flutter 2.x.

## Branch `with-blinkcard-ios-3000.0.1`

The same app with a local copy of `blinkcard_flutter` 3000.0.0 in `blinkcard_flutter_patched/`. The only change is in `ios/blinkcard_flutter/Package.swift`:

```diff
-        .package(url: "https://github.com/BlinkCard/blinkcard-ios.git", exact: .init(3000, 0, 0))
+        .package(url: "https://github.com/BlinkCard/blinkcard-ios.git", exact: .init(3000, 0, 1))
```

(plus the matching `Package.resolved`). blinkcard-ios 3000.0.1 replaces the `canImport` checks with its own `BLINKCARDUX` compile flag, and this branch builds with the same command.

## Request

Please publish a `blinkcard_flutter` release that depends on blinkcard-ios 3000.0.1 or newer.
