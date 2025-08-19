import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../utils/constants.dart';
import '../../widgets/ModernAppBar.dart';

class ReadFile extends StatefulWidget {
  final String assetPath;

  const ReadFile({Key? key, required this.assetPath}) : super(key: key);

  @override
  State<ReadFile> createState() => _ReadFileState();
}

class _ReadFileState extends State<ReadFile> {
  PdfControllerPinch? _pdfController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openAsset(widget.assetPath),
      );
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error if needed
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Document',
        subtitle: 'Viewer',
        onMenuPressed: () {
          Navigator.pop(context);
        },
        actions: [
          IconButton(
            icon: const Icon(
              Icons.fullscreen_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // Add fullscreen functionality if needed
            },
            tooltip: "Fullscreen",
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: kPrimaryColor,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading document...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _pdfController == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Failed to load document",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please try again later",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : PdfViewPinch(
                  controller: _pdfController!,
                ),
    );
  }
}
