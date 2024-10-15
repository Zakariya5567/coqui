import 'package:coqui/utils/colors.dart';
import 'package:coqui/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFReaderScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  PDFReaderScreen({required this.filePath,required this.fileName});

  @override
  _PDFReaderScreenState createState() => _PDFReaderScreenState();
}

class _PDFReaderScreenState extends State<PDFReaderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.blackPrimary,
      appBar: AppBar(
        backgroundColor: AppColor.blackPrimary,
        title: Text(widget.fileName,style: const TextStyle(
          color: AppColor.whitePrimary,
          fontSize: 26,
          fontFamily: AppStyle.gothamMedium
        ),),
      ),
      body: PDFView(
        filePath: widget.filePath, // Path to your PDF file
        enableSwipe: true, // Enable swipe to change pages
        swipeHorizontal: true, // Horizontal swipe for page navigation
        autoSpacing: true, // Enable auto spacing
        pageFling: true, // Enable page fling
        pageSnap: true, // Enable page snap (snap to page)
        defaultPage: 0, // Initial page
        fitPolicy: FitPolicy.BOTH, // How the PDF should fit into the screen
      ),
    );
  }
}
