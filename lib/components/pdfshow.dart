import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;
  const PdfViewerPage({Key? key, required this.pdfUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Viewer'),
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        canShowPaginationDialog: true,
      ),
    );
  }
}
