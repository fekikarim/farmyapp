import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: \${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print('Message also contained a notification: \${message.notification}');
        }
        // You can show a local notification here if needed
      }
    });

    // Handle message open app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
      }
      // Navigate to specific screen based on data
    });
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  static Future<String> getDeviceFingerprint() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id; // Unique ID on Android
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      } else if (kIsWeb) {
        WebBrowserInfo webBrowserInfo = await _deviceInfo.webBrowserInfo;
        return webBrowserInfo.userAgent ?? 'unknown_web';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device fingerprint: \$e');
      }
    }
    return 'unknown_device';
  }

  static String getPlatformName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }

  static Future<void> syncTokenWithBackend() async {
    try {
      String? token = await getToken();
      if (token == null) return;

      String fingerprint = await getDeviceFingerprint();
      String platform = getPlatformName();

      final authService = AuthService();
      await authService.registerDevice(token, fingerprint, platform);
      
      if (kDebugMode) {
        print('Device token synced with backend: \$token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing token: \$e');
      }
    }
  }
}
