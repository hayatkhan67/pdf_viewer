import 'package:easy_pdf_viewer_plus/easy_pdf_viewer_plus.dart';
import 'package:flutter/material.dart';

class WithProgress extends StatefulWidget {
  WithProgress({Key? key}) : super(key: key);

  @override
  State<WithProgress> createState() => _WithProgressState();
}

class _WithProgressState extends State<WithProgress> {
  bool _isLoading = true;
  late PDFDocument document;
  DownloadProgress? downloadProgress;

  @override
  void initState() {
    loadDocument();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void loadDocument() async {
    /// Clears the cache before download, so [PDFDocument.fromURLWithDownloadProgress.downloadProgress()]
    /// is always executed (meant only for testing).
    await DefaultCacheManager().emptyCache();

    PDFDocument.fromURLWithDownloadProgress(
      'https://www.africau.edu/images/default/sample.pdf',
      downloadProgress: (downloadProgress) => setState(() {
        this.downloadProgress = downloadProgress;
      }),
      onDownloadComplete: (document) => setState(() {
        this.document = document;
        _isLoading = false;
      }),
    );
  }

  Widget buildProgress() {
    if (downloadProgress == null) return SizedBox();

    String parseBytesToKBs(int? bytes) {
      if (bytes == null) return '0 KBs';

      return '${(bytes / 1000).toStringAsFixed(2)} KBs';
    }

    String progressString = parseBytesToKBs(downloadProgress!.downloaded);
    if (downloadProgress!.totalSize != null) {
      progressString += '/ ${parseBytesToKBs(downloadProgress!.totalSize)}';
    }

    return Column(
      children: [
        SizedBox(height: 20),
        Text(progressString),
      ],
    );
  }

  changePDF(value) async {
    setState(() => _isLoading = true);
    if (value == 1) {
      document = await PDFDocument.fromAsset('assets/sample2.pdf');
    } else if (value == 2) {
      document = await PDFDocument.fromURL(
        "https://www.africau.edu/images/default/sample.pdf",

        /* cacheManager: CacheManager(
          Config(
            "customCacheKey",
            stalePeriod: const Duration(days: 2),
            maxNrOfCacheObjects: 10,
          ),
        ), */
      );
    } else {
      document = await PDFDocument.fromAsset('assets/sample.pdf');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            SizedBox(height: 36),
            ListTile(
              title: Text('Load from Assets'),
              onTap: () {
                changePDF(1);
              },
            ),
            ListTile(
              title: Text('Load from URL'),
              onTap: () {
                changePDF(2);
              },
            ),
            ListTile(
              title: Text('Restore default'),
              onTap: () {
                changePDF(3);
              },
            ),
            ListTile(
              title: Text('With Progress'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WithProgress(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('PDFViewer'),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    buildProgress(),
                  ],
                ),
              )
            : PDFViewer(
                document: document,
                numberPickerConfirmWidget: const Text(
                  "Confirm",
                ),
              ),
      ),
    );
  }
}
