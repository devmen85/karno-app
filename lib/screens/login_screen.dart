import 'package:flutter/material.dart';
import '../services/woocommerce_api.dart';
import 'product_list_screen.dart';
import 'qr_scanner_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();
  final _secretController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = WooCommerceApi();
    await api.saveCredentials(
      url: _urlController.text.trim(),
      key: _keyController.text.trim(),
      secret: _secretController.text.trim(),
    );

    final ok = await api.testConnection();

    setState(() => _loading = false);

    if (ok && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProductListScreen()),
      );
    } else {
      setState(() => _error =
          'اتصال ناموفق بود. آدرس سایت و کلیدهای API را بررسی کنید.');
    }
  }

  Future<void> _scanQr() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (result != null) {
      setState(() {
        _urlController.text = result['url'] ?? '';
        _keyController.text = result['key'] ?? '';
        _secretController.text = result['secret'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.storefront, size: 64, color: Colors.deepPurple),
                const SizedBox(height: 16),
                Text('اتصال به فروشگاه ووکامرس',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'آدرس سایت',
                    hintText: 'https://yourstore.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (v) =>
                      (v == null || !v.startsWith('http')) ? 'آدرس معتبر وارد کنید' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _keyController,
                  decoration: const InputDecoration(
                    labelText: 'Consumer Key',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'الزامی' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _secretController,
                  decoration: const InputDecoration(
                    labelText: 'Consumer Secret',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => (v == null || v.isEmpty) ? 'الزامی' : null,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _scanQr,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('اسکن QR Code به‌جای وارد کردن دستی'),
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                FilledButton(
                  onPressed: _loading ? null : _connect,
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('اتصال'),
                ),
                const SizedBox(height: 16),
                Text(
                  'راهنما: کلیدهای API را از مسیر زیر در سایت خود بسازید:\n'
                  'WooCommerce > Settings > Advanced > REST API > Add key\n'
                  '(دسترسی Read/Write را انتخاب کنید)',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
