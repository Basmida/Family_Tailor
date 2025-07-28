import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransPaymentPage extends StatefulWidget {
  final String token;

  const MidtransPaymentPage({super.key, required this.token});

  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  bool _isLoading = true;
  late final String paymentUrl;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    paymentUrl =
        'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.token}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Midtrans'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF270650), Color(0xFFFF30BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF270650), // Sesuaikan warna loading
                strokeWidth: 3,
              ),
            ),
        ],
      ),
    );
  }
}
