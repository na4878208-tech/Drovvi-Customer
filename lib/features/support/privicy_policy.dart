import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../common_widgets/custom_text.dart';
import '../../../../constants/colors.dart';

class TermsPrivacyWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const TermsPrivacyWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<TermsPrivacyWebViewScreen> createState() =>
      _TermsPrivacyWebViewScreenState();
}

class _TermsPrivacyWebViewScreenState extends State<TermsPrivacyWebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background while loading
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: CustomText(txt: widget.title, fontSize: 18, color: Colors.white),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.electricTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            Container(
              color: Colors.white, // White overlay while page loads
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.electricTeal),
              ),
            ),
        ],
      ),
    );
  }
}
