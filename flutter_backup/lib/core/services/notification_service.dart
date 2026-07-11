import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Top-level callback dispatcher for Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint("Workmanager task executing: $taskName");
    try {
      // 1. Fetch token and convex url
      const secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        debugPrint("No auth token found, skipping background notification check.");
        return true;
      }

      const convexUrl = String.fromEnvironment('CONVEX_URL');
      if (convexUrl.isEmpty) {
        debugPrint("CONVEX_URL is empty, skipping background check.");
        return true;
      }

      // 2. Fetch unread notifications from Convex HTTP API
      final url = Uri.parse("$convexUrl/api/query");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "path": "notifications:listUnread",
          "args": {"sessionToken": token},
          "format": "json"
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['value'] is List) {
          final unreadList = List<Map<String, dynamic>>.from(
            (data['value'] as List).map((e) => Map<String, dynamic>.from(e as Map))
          );
          
          if (unreadList.isNotEmpty) {
            // Get last seen notification ID
            String? lastSeenId;
            try {
              lastSeenId = await secureStorage.read(key: 'last_seen_notif_id');
            } catch (_) {}
            
            // Fallback file storage if secure storage fails in isolate
            final fallbackFile = File('${Directory.systemTemp.path}/.last_seen_notif.txt');
            if (lastSeenId == null && await fallbackFile.exists()) {
              lastSeenId = await fallbackFile.readAsString();
            }

            final newNotifications = unreadList.where((n) => n['_id'] != lastSeenId).toList();
            
            if (newNotifications.isNotEmpty) {
              final latest = newNotifications.first;
              final latestId = latest['_id'] as String;
              final title = latest['title'] as String? ?? 'SLG Golds';
              final message = latest['message'] as String? ?? '';

              // Show local notification banner
              final fln = FlutterLocalNotificationsPlugin();
              const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
              const initSettings = InitializationSettings(android: androidSettings);
              await fln.initialize(initSettings);

              const androidDetails = AndroidNotificationDetails(
                'slg_notifications_channel',
                'General Notifications',
                channelDescription: 'New updates and savings alerts',
                importance: Importance.max,
                priority: Priority.high,
              );
              const details = NotificationDetails(android: androidDetails);
              await fln.show(
                latestId.hashCode,
                title,
                message,
                details,
              );

              // Update last seen ID
              try {
                await secureStorage.write(key: 'last_seen_notif_id', value: latestId);
              } catch (_) {}
              try {
                await fallbackFile.writeAsString(latestId);
              } catch (_) {}
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error in background notification task: $e");
    }
    return true;
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  Timer? _foregroundTimer;

  Future<void> initialize() async {
    if (kIsWeb) return;

    // 1. Initialize Local Notifications Plugin
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _fln.initialize(initSettings);

    // 2. Initialize Workmanager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // 3. Register a periodic task for workmanager
    await Workmanager().registerPeriodicTask(
      "slg_notification_polling_task",
      "pollUnreadNotifications",
      frequency: const Duration(minutes: 5),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );

    // 4. Start foreground polling (every 5 minutes)
    _startForegroundPolling();
  }

  void _startForegroundPolling() {
    _foregroundTimer?.cancel();
    _foregroundTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      triggerForegroundCheck();
    });
    // Run an initial check immediately
    triggerForegroundCheck();
  }

  Future<void> triggerForegroundCheck() async {
    try {
      const secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) return;

      const convexUrl = String.fromEnvironment('CONVEX_URL');
      if (convexUrl.isEmpty) return;

      final url = Uri.parse("$convexUrl/api/query");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "path": "notifications:listUnread",
          "args": {"sessionToken": token},
          "format": "json"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['value'] is List) {
          final unreadList = List<Map<String, dynamic>>.from(
            (data['value'] as List).map((e) => Map<String, dynamic>.from(e as Map))
          );
          
          if (unreadList.isNotEmpty) {
            final latest = unreadList.first;
            final latestId = latest['_id'] as String;
            
            final lastSeenId = await secureStorage.read(key: 'last_seen_notif_id');
            if (latestId != lastSeenId) {
              // Show notification banner
              const androidDetails = AndroidNotificationDetails(
                'slg_notifications_channel',
                'General Notifications',
                channelDescription: 'New updates and savings alerts',
                importance: Importance.max,
                priority: Priority.high,
              );
              const details = NotificationDetails(android: androidDetails);
              await _fln.show(
                latestId.hashCode,
                latest['title'] as String? ?? 'SLG Golds',
                latest['message'] as String? ?? '',
                details,
              );

              await secureStorage.write(key: 'last_seen_notif_id', value: latestId);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error in foreground check: $e");
    }
  }

  void stop() {
    _foregroundTimer?.cancel();
  }
}
