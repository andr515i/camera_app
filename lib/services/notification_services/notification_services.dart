import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  int index = 0;

  // initialize notification settings for android and ios
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
    debugPrint(
        'handlemesage: ${message.messageId.toString()} Payload: ${payload.payload}');
  }

// request permissions for notifications
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
      debugPrint('all permissions granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('only provisional granted.');
    } else {
      debugPrint('no permission granted');
    }
  }

  ///subscribes to "camera-app-topic-firebase".
  ///
  ///also listens to incoming messages via the FirebaseMessaging.onMessage.listen method, and sends notifications based on platform (ios or android)
  ///
  void firebaseInit() {
    FirebaseMessaging.instance.subscribeToTopic("camera-app-topic-firebase");

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      debugPrint("notifications title:${notification!.title}");
      debugPrint("notifications body:${notification.body}");
      debugPrint('count:${android!.count}');
      debugPrint('id: ${android.channelId}');
      debugPrint('data:${message.data.toString()}');

      if (Platform.isIOS) {
        _forgroundMessage();
      }

      if (Platform.isAndroid) {
        _initLocalNotifications(message);
        _showNotification(message);
      }
    });
  }

  /// ios specific foreground only notifications. havent tested on ios, but thought it might be alright to keep in just in case.
  /// this means that it hasnt been tested, and is most likely just the default notifcation with no title or body. not sure though.
  Future _forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
  }

  /// android mainly but not specfic foreground only notification
  Future<void> _showNotification(RemoteMessage message) async {
// initialize a channel for use with the android details. not actually necessary, but might be good practice to keep it in.
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        index.toString(), "eagle sound",
        importance: Importance
            .max, // max so that we get the notification this century instead of the next.
        showBadge: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound(
            "eagle")); // custom sound.

// the details used for android notifcations
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channel.id.toString(), channel.name.toString(),
        channelDescription: "the channel description.",
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        ticker: "ticker tick",
        sound: channel.sound);

// darwin details, not really tested or used, but might aswell keep in.
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

// the details get thrown together so that we can use just one further down
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: darwinDetails);

// experimental payload
    var ext = '';
    for (MapEntry<String, dynamic> item in message.data.entries) {
      ext += item.value as String;
      ext += '|';
    }

    debugPrint('values: $ext');

    // experiment to show the notification every minute. hint - doesnt work.
    // await _localPlugin.periodicallyShow(
    //   index,
    //   "repeating title",
    //   "repeating body",
    //   RepeatInterval.everyMinute,
    //   notificationDetails,
    // );

    // show the notification
    Future.delayed(Duration.zero, () {
      _localPlugin.show(index, message.notification?.title.toString(),
          message.notification?.body.toString(), notificationDetails,
          payload: ext);
    });

    index++; // index is the id used for notifications. need to increase incase we ever want to show a different notification
  }
}
