import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'woocommerce_api.dart';

/// Polls the WooCommerce store for newly created orders and raises a local
/// notification + alarm-style sound, similar to Woocer's "Order Alarm" feature.
///
/// NOTE ON BACKGROUND EXECUTION:
/// This polls on a timer while the app is in the foreground. For true
/// background/killed-app notifications (like the real Woocer app), you need
/// either:
///   (a) a server-side webhook (WooCommerce > Settings > Advanced > Webhooks
///       on "order.created") that calls a push service (e.g. Firebase Cloud
///       Messaging), or
///   (b) the `workmanager` package registered as a periodic background task
///       (Android allows a minimum ~15 min interval; iOS background fetch is
///       even less reliable — Apple restricts frequent background execution).
/// Option (a) is the approach the official app effectively uses and is far
/// more reliable/instant than polling. This starter ships the simple
/// foreground-polling version so it works out of the box without extra
/// backend setup.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _player = AudioPlayer();
  Timer? _pollTimer;
  final _api = WooCommerceApi();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  /// Call once after login / on app startup to begin foreground polling.
  /// [intervalSeconds] controls how often we check (default: 60s).
  void startPolling({int intervalSeconds = 60}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) => _checkForNewOrders());
    _checkForNewOrders(); // run once immediately
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _checkForNewOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckStr = prefs.getString('last_order_check');
    final lastCheck = lastCheckStr != null
        ? DateTime.parse(lastCheckStr)
        : DateTime.now().subtract(const Duration(minutes: 5));

    try {
      final newOrders = await _api.getOrdersCreatedAfter(lastCheck);
      for (final order in newOrders) {
        await _notify(order.id, order.customerName, order.total);
      }
      await prefs.setString('last_order_check', DateTime.now().toIso8601String());
    } catch (_) {
      // Network/auth errors are silently skipped; next poll will retry.
    }
  }

  Future<void> _notify(int orderId, String customerName, String total) async {
    // Play alarm-style sound.
    // Add your own sound file at assets/sounds/order_alert.mp3 and declare it
    // in pubspec.yaml under flutter > assets for this to play.
    try {
      await _player.play(AssetSource('sounds/order_alert.mp3'));
    } catch (_) {
      // Falls back silently if asset isn't bundled yet.
    }

    const androidDetails = AndroidNotificationDetails(
      'new_orders_channel',
      'سفارش‌های جدید',
      channelDescription: 'اعلان برای سفارش‌های تازه ثبت‌شده',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _plugin.show(
      orderId,
      'سفارش جدید دریافت شد 🎉',
      '${customerName.isEmpty ? "مشتری" : customerName} - $total تومان',
      details,
    );
  }
}
