# easy_pdf_viewer_plus

A Flutter plugin for handling PDF files. Works on both Android & iOS.

This is an upgraded and actively maintained fork of [easy_pdf_viewer](https://pub.dev/packages/easy_pdf_viewer) (which has not been updated in over 2 years), maintained by [hayatkhan67](https://github.com/hayatkhan67).

[![Pub Package](https://img.shields.io/pub/v/easy_pdf_viewer_plus.svg?style=flat-square)](https://pub.dev/packages/easy_pdf_viewer_plus)


## Installation

```
> flutter pub add easy_pdf_viewer_plus
```

---

## Android
No permissions required. Uses application cache directory.

## iOS
No permissions required.

## How-to:

#### Load PDF
```dart
// Load from assets
PDFDocument doc = await PDFDocument.fromAsset('assets/test.pdf');
 
// Load from URL
PDFDocument doc = await PDFDocument.fromURL('https://www.ecma-international.org/wp-content/uploads/ECMA-262_12th_edition_june_2021.pdf');

// Load from file
File file  = File('...');
PDFDocument doc = await PDFDocument.fromFile(file);
```

#### Load pages
```dart
// Load specific page
PDFPage pageOne = await doc.get(page: _number);
```

#### Pre-built viewer
Use the pre-built PDF Viewer
```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(document: document)),
    );
  }
```

This code produces the following view:

![demo](./demo.png)

#### Third-party packages used

| Name                                                                                             | Description                                                                                                                               |
| ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| [path_provider](https://pub.dev/packages/path_provider)                                          | A Flutter plugin for finding commonly used locations on the filesystem. Supports iOS and Android.                                         |
| [flutter_cache_manager](https://pub.dev/packages/flutter_cache_manager)                          | A CacheManager to download and cache files in the cache directory of the app. Various settings on how long to keep a file can be changed. |
| [numberpicker](https://pub.dev/packages/numberpicker)                                            | NumberPicker is a custom widget designed for choosing an integer or decimal number by scrolling spinners.                                 |

## Credits & Fork Info

This package is an upgraded fork and continuation of the original packages:
* **[easy_pdf_viewer](https://pub.dev/packages/easy_pdf_viewer)** (developed/maintained by **Kaichi**, contact@kaichi.dev)
* **[flutter_plugin_pdf_viewer](https://pub.dev/packages/flutter_plugin_pdf_viewer)** (originally created by **Tiago Ribeiro**, the foundation for all these PDF viewer plugins)

### Maintainer

This fork is actively maintained by **[Hayat Khan (hayatkhan67)](https://github.com/hayatkhan67)**. If you have any issues, feel free to open a pull request or issue on the GitHub repository.

