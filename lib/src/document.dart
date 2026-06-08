import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:easy_pdf_viewer_plus/src/page.dart';
import 'package:path_provider/path_provider.dart';

class PDFDocument {
  static const MethodChannel _channel =
      const MethodChannel('easy_pdf_viewer_plugin');

  String? _filePath;
  late int count;
  List<PDFPage> _pages = [];
  bool _preloaded = false;

  /// expose file path for pdf sharing capabilities
  String? get filePath => _filePath;

  /// Load a PDF File from a given File
  /// [File file], file to be loaded
  ///
  /// Automatically clears the on-disk cache of previously rendered PDF previews
  /// unless [clearPreviewCache] is set to `false`. The option to disable it
  /// comes in handy when working with more than one document at the same time.
  /// If you do this, you are responsible for eventually clearing the cache by hand
  /// by calling [PDFDocument.clearPreviewCache].
  static Future<PDFDocument> fromFile(File file,
      {bool clearPreviewCache = true}) async {
    PDFDocument document = PDFDocument();
    document._filePath = file.path;
    try {
      var pageCount = await _channel.invokeMethod('getNumberOfPages',
          {'filePath': file.path, 'clearCacheDir': clearPreviewCache});
      document.count = document.count = int.parse(pageCount);
    } catch (e) {
      throw Exception('Error reading PDF!');
    }
    return document;
  }

  /// Load a PDF File from a given URL.
  /// File is saved in cache
  /// 
  /// [String url] url of the pdf file
  /// [Map<String,String headers] headers to pass for the [url]
  /// [CacheManager cacheManager] to provide configuration for
  /// cache management
  /// Automatically clears the on-disk cache of previously rendered PDF previews
  /// unless [clearPreviewCache] is set to `false`. The option to disable it
  /// comes in handy when working with more than one document at the same time.
  /// If you do this, you are responsible for eventually clearing the cache by hand
  /// by calling [PDFDocument.clearPreviewCache].
  static Future<PDFDocument> fromURL(String url,
      {Map<String, String>? headers, CacheManager? cacheManager, clearPreviewCache = true}) async {
    // Download into cache
    File f = await (cacheManager ?? DefaultCacheManager())
        .getSingleFile(url, headers: headers);
    PDFDocument document = PDFDocument();
    document._filePath = f.path;
    try {
      var pageCount = await _channel.invokeMethod('getNumberOfPages',
          {'filePath': f.path, 'clearCacheDir': clearPreviewCache});
      document.count = document.count = int.parse(pageCount);
    } catch (e) {
      throw Exception('Error reading PDF!');
    }
    return document;
  }

  /// Load a PDF File from a given URL, notifies download progress until completed
  /// File is saved in cache
  /// 
  /// [String url] url of the pdf file
  /// [Map<String,String headers] headers to pass for the [url]
  /// [CacheManager cacheManager] to provide configuration for
  /// cache management
  /// Automatically clears the on-disk cache of previously rendered PDF previews
  /// unless [clearPreviewCache] is set to `false`. The option to disable it
  /// comes in handy when working with more than one document at the same time.
  /// If you do this, you are responsible for eventually clearing the cache by hand
  /// by calling [PDFDocument.clearPreviewCache].
  /// Use [downloadProgress] to get the download progress information. NOTE that 
  /// [downloadProgress] is not called after [onDownloadComplete].
  /// Once the download is finished, [onDownloadComplete] is called. If the file
  /// is already available, [onDownloadComplete] is called directly.
  static void fromURLWithDownloadProgress(
    String url, {
    Map<String, String>? headers,
    CacheManager? cacheManager,
    bool clearPreviewCache = true,
    required void Function(DownloadProgress downloadProgress) downloadProgress,
    required void Function(PDFDocument document) onDownloadComplete,
  }) {
    StreamSubscription<FileResponse>? streamSubscription;
    final fileResponse = (cacheManager ?? DefaultCacheManager())
        .getFileStream(url, headers: headers, withProgress: true);

    streamSubscription = fileResponse.listen(
      (event) async {
        if (event is DownloadProgress) {
          downloadProgress.call(event);
          return;
        }

        if (event is FileInfo) {
          final pdfDocument =
              await fromFile(event.file, clearPreviewCache: clearPreviewCache);
          onDownloadComplete.call(pdfDocument);
          streamSubscription?.cancel();
          return;
        }
      },
    );
  }
  
  /// Load a PDF File from assets folder
  /// 
  /// [String asset] path of the asset to be loaded
  /// Automatically clears the on-disk cache of previously rendered PDF previews
  /// unless [clearPreviewCache] is set to `false`. The option to disable it
  /// comes in handy when working with more than one document at the same time.
  /// If you do this, you are responsible for eventually clearing the cache by hand
  /// by calling [PDFDocument.clearPreviewCache].
  static Future<PDFDocument> fromAsset(String asset,
      {clearPreviewCache = true}) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    File file;
    try {
      var dir = await getApplicationDocumentsDirectory();
      file = File("${dir.path}/file.pdf");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
    PDFDocument document = PDFDocument();
    document._filePath = file.path;
    try {
      var pageCount = await _channel.invokeMethod('getNumberOfPages',
          {'filePath': file.path, 'clearCacheDir': clearPreviewCache});
      document.count = document.count = int.parse(pageCount);
    } catch (e) {
      throw Exception('Error reading PDF!');
    }
    return document;
  }

  /// Clears an on-disk cache of previously rendered PDF previews.
  ///
  /// This is normally done automatically by methods such as [fromFile],
  /// [fromURL], and [fromAsset], unless they are run with the
  /// `clearPreviewCache` parameter set to `false`.
  static Future<void> clearPreviewCache() async {
    await _channel.invokeMethod('clearCacheDir');
  }

  /// Load specific page
  ///
  /// [page] defaults to `1` and must be equal or above it
  Future<PDFPage> get({
    int page = 1,
    final Function(double)? onZoomChanged,
    final int? zoomSteps,
    final double? minScale,
    final double? maxScale,
    final double? panLimit,
  }) async {
    assert(page > 0);
    if (_preloaded && _pages.isNotEmpty) return _pages[page - 1];
    var data = await _channel
        .invokeMethod('getPage', {'filePath': _filePath, 'pageNumber': page});
    return new PDFPage(
      data,
      page,
      onZoomChanged: onZoomChanged,
      zoomSteps: zoomSteps ?? 3,
      minScale: minScale ?? 1.0,
      maxScale: maxScale ?? 5.0,
      panLimit: panLimit ?? 1.0,
    );
  }

  Future<void> preloadPages({
    final Function(double)? onZoomChanged,
    final int? zoomSteps,
    final double? minScale,
    final double? maxScale,
    final double? panLimit,
  }) async {
    int countvar = 1;
    for (final _ in List.filled(count, null)) {
      final data = await _channel.invokeMethod(
          'getPage', {'filePath': _filePath, 'pageNumber': countvar});
      _pages.add(PDFPage(
        data,
        countvar,
        onZoomChanged: onZoomChanged,
        zoomSteps: zoomSteps ?? 3,
        minScale: minScale ?? 1.0,
        maxScale: maxScale ?? 5.0,
        panLimit: panLimit ?? 1.0,
      ));
      countvar++;
    }
    _preloaded = true;
  }

  // Stream all pages
  Stream<PDFPage?> getAll({final Function(double)? onZoomChanged}) {
    return Future.forEach<PDFPage?>(List.filled(count, null), (i) async {
      print(i);
      final data = await _channel
          .invokeMethod('getPage', {'filePath': _filePath, 'pageNumber': i});
      return new PDFPage(
        data,
        1,
        onZoomChanged: onZoomChanged,
      );
    }).asStream() as Stream<PDFPage?>;
  }
}
