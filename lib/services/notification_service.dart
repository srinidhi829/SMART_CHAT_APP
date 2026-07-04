import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM Token
    String? token = await messaging.getToken();

    print("FCM TOKEN:");
    print(token);

    // Refresh Token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("NEW TOKEN:");
      print(newToken);
    });
  }
}