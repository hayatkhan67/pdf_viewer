import 'dart:io';
import 'package:easy_pdf_viewer_plus_example/with_progress.dart';
import 'package:flutter/material.dart';
import 'package:easy_pdf_viewer_plus/easy_pdf_viewer_plus.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy PDF Viewer Plus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, this.progressExample = false}) : super(key: key);

  final bool progressExample;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    document = await PDFDocument.fromAsset('assets/sample.pdf');
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  changePDF(int value) async {
    setState(() => _isLoading = true);
    try {
      if (value == 1) {
        document = await PDFDocument.fromAsset('assets/sample2.pdf');
      } else if (value == 2) {
        document = await PDFDocument.fromURL(
          "https://www.africau.edu/images/default/sample.pdf",
        );
      } else {
        document = await PDFDocument.fromAsset('assets/sample.pdf');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isLoading = true);
        document = await PDFDocument.fromFile(File(result.files.single.path!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking or loading PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.picture_as_pdf,
                    size: 40, color: Colors.deepPurple),
              ),
              accountName: Text(
                'PDF Viewer Plus',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Text('v2.0.0'),
            ),
            ListTile(
              leading:
                  const Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
              title: const Text('Load from Assets'),
              onTap: () {
                Navigator.pop(context);
                changePDF(1);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.cloud_download, color: Colors.deepPurple),
              title: const Text('Load from URL'),
              onTap: () {
                Navigator.pop(context);
                changePDF(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.deepPurple),
              title: const Text('Pick and Load PDF'),
              onTap: () {
                Navigator.pop(context);
                _pickPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.deepPurple),
              title: const Text('Restore default'),
              onTap: () {
                Navigator.pop(context);
                changePDF(3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.deepPurple),
              title: const Text('With Progress Example'),
              onTap: () {
                Navigator.pop(context);
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
        title: const Text('PDFViewer Plus'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : PDFViewer(
                document: document,
                lazyLoad: false,
                zoomSteps: 1,
                numberPickerConfirmWidget: const Text(
                  "Confirm",
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickPDF,
        label: const Text('Pick PDF'),
        icon: const Icon(Icons.folder_open),
        tooltip: 'Pick PDF from Device',
      ),
    );
  }
}
