import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scans a QR code and returns the decoded credentials to the caller.
/// Supports two formats:
///  1. JSON: {"url": "...", "consumer_key": "...", "consumer_secret": "..."}
///  2. Pipe-delimited: url|consumer_key|consumer_secret
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    Map<String, String>? result;

    // Try JSON format first.
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      result = {
        'url': decoded['url']?.toString() ?? '',
        'key': decoded['consumer_key']?.toString() ?? '',
        'secret': decoded['consumer_secret']?.toString() ?? '',
      };
    } catch (_) {
      // Fall back to pipe-delimited format.
      final parts = raw.split('|');
      if (parts.length == 3) {
        result = {'url': parts[0], 'key': parts[1], 'secret': parts[2]};
      }
    }

    if (result != null && result['url']!.isNotEmpty) {
      _handled = true;
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اسکن QR Code کلید API')),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'دوربین را روی QR Code تولیدشده از تنظیمات REST API سایت‌تان بگیرید',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
