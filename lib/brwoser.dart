import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';

class MyBrowser extends StatefulWidget {
  String url;
  MyBrowser(this.url, {super.key});

  @override
  State<MyBrowser> createState() => _MyBrowserState();
}

class _MyBrowserState extends State<MyBrowser> {
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.url,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          automaticallyImplyLeading: true,
        ),
        body: Stack(
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox(),
            InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
              onLoadStop: (c, u) {
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        ));
  }
}
