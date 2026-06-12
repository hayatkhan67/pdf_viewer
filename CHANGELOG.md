## 2.0.1

- Fix PDF showing blank issue

## 2.0.0

- **BREAKING**: Renamed package from `easy_pdf_viewer` to `easy_pdf_viewer_plus`
- **BREAKING**: Bumped minimum Dart SDK to `>=3.6.0`
- **BREAKING**: Android `minSdkVersion` raised from 16 to 21
- **BREAKING**: iOS minimum deployment target raised from 9.0 to 13.0
- Upgraded Android Gradle Plugin to 8.7.3, Gradle to 8.10.2
- Replaced deprecated `jcenter()` with `mavenCentral()`
- Updated `flutter_cache_manager` to ^3.4.1
- Updated `path_provider` to >=2.1.5 <3.0.0
- Removed deprecated `@RequiresApi` annotations (minSdk 21 guarantees API availability)
- Replaced deprecated `Handler()` with `Handler(Looper.getMainLooper())`
- Removed `android.enableJetifier` (no longer needed)
- Added Java 17 compatibility

## 1.0.8

- Add param onZoomChanged to PDFViewer

## 1.0.7

- Upgrade some deps
- Modify example code

## 1.0.6

- Fix setState being called wrong

## 1.0.5

- Fix missing parameter

## 1.0.4

- Fix deprecated API

## 1.0.3

- Add progress status

## 1.0.2

- Support multiple files

## 1.0.1

- Support the v2 Android embedder.

## 1.0.0

- fix lazyload after fork
