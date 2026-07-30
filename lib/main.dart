import 'package:flutter/material.dart';
import 'services/woocommerce_api.dart';
import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(const WoocerApp());
}

class WoocerApp extends StatelessWidget {
  const WoocerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Woocer - مدیریت محصولات ووکامرس',
      debugShowCheckedModeBanner: false,
      // RTL support for Persian UI
      locale: const Locale('fa', 'IR'),
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        fontFamily: 'Vazir', // add a Persian font (e.g. Vazirmatn) to assets for proper rendering
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/products': (context) => const ProductListScreen(),
      },
      home: const _StartupGate(),
    );
  }
}

/// Checks for saved credentials on launch and routes accordingly.
class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  bool? _hasCredentials;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ok = await WooCommerceApi().loadSavedCredentials();
    setState(() => _hasCredentials = ok);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCredentials == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _hasCredentials! ? const ProductListScreen() : const LoginScreen();
  }
}
