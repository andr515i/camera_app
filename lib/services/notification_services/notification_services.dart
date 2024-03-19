import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  int index = 0;
  void _initLocalNotifications(RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _localPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
      // handle interaction when app is active for android
      _handleMessage(payload, message);
    });
  }

  void _handleMessage(NotificationResponse payload, RemoteMessage message) {
    //Do something in the app when the notification is tapped
    if (kDebugMode) {
      print(
          'handlemesage: ${message.messageId.toString()} Payload: ${payload.payload}');
    }
  }

  void requestNotificationPermissions() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
            alert: true,
            announcement: true,
            badge: true,
            carPlay: true,
            criticalAlert: true,
            provisional: true,
            sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        debugPrint('all permissions granted');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        debugPrint('only provisional granted.');
      }
    } else {
      if (kDebugMode) {
        debugPrint('no permission granted');
      }
    }
  }

  void firebaseInit() {
    FirebaseMessaging.instance.subscribeToTopic("images_completed");

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (kDebugMode) {
        print("notifications title:${notification!.title}");
        print("notifications body:${notification.body}");
        print('count:${android!.count}');
        print('id: ${android.channelId}');
        print('data:${message.data.toString()}');
      }

      if (Platform.isIOS) {
        _forgroundMessage();
      }

      if (Platform.isAndroid) {
        _initLocalNotifications(message);
        _showNotification(message);
      }
    });
  }

  Future _forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        index.toString(), "eagle sound",
        importance: Importance.max,
        showBadge: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound("eagle"));

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channel.id.toString(), channel.name.toString(),
        channelDescription: "the channel description.",
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        ticker: "ticker tick",
        sound: channel.sound);

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: darwinDetails);

    var ext = '';

    for (MapEntry<String, dynamic> item in message.data.entries) {
      ext += item.value as String;
      ext += '|';
    }

    debugPrint('values: $ext');
    await _localPlugin.periodicallyShow(index, "repeating title",
        "repeating body", RepeatInterval.everyMinute, notificationDetails,
        );

    Future.delayed(Duration.zero, () {
      _localPlugin.show(index, message.notification?.title.toString(),
          message.notification?.body.toString(), notificationDetails,
          payload: ext);
    });


    index++;
  }

//refresh fcm token
Future<void> isTokenRefresh() async{
  FirebaseMessaging.instance.onTokenRefresh.listen((event) {
    event.toString();
    debugPrint("refresh");
  });
}
  
}
