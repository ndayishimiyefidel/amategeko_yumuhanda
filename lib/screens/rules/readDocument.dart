import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../utils/constants.dart';

class ReadFile extends StatefulWidget {
  final String fileUrl;

  const ReadFile({Key? key, required this.fileUrl}) : super(key: key);

  @override
  State<ReadFile> createState() => _ReadFileState();
}

class _ReadFileState extends State<ReadFile> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                _pdfViewerStateKey.currentState!.openBookmarkView();
              },
              icon: const Icon(
                Icons.bookmark,
                color: Colors.white,
              )),
          IconButton(
              onPressed: () {
                _pdfViewerController.jumpToPage(5);
              },
              icon: const Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.white,
              )),
          IconButton(
              onPressed: () {
                _pdfViewerController.zoomLevel = 1.25;
              },
              icon: const Icon(
                Icons.zoom_in,
                color: Colors.white,
              ))
        ],
      ),
      body: SfPdfViewer.network(
        widget.fileUrl,
        controller: _pdfViewerController,
        key: _pdfViewerStateKey,
      ),
    );
  }
}
