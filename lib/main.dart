// main.dart
import 'dart:async';
import 'dart:isolate';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:camera_app/firebase_options.dart';
import 'package:camera_app/interfaces/Camera_app_db_inteface.dart';
import 'package:camera_app/providers/repositories/MockRepo.dart';
import 'package:camera_app/providers/repositories/PictureRepo.dart';
import 'package:camera_app/screens/login_screen.dart';
import 'package:camera_app/services/notification_services/notification_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:camera_app/screens/camera_screen.dart';
import 'package:camera_app/screens/gallery_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:camera_app/providers/camera_provider.dart';

late CameraController _cameraController;
final NotificationService _notificationService = NotificationService();
var index = 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint(await FirebaseMessaging.instance.getToken());
  _notificationService.requestNotificationPermissions();
  _notificationService.firebaseInit();

  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

  await _setupCamera();

  runApp(MyApp());
}


@pragma('vm:entry-point', )
Future<void> _backgroundHandler(RemoteMessage message) async {
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

     NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);
        FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
    await plugin.show(
        100 + index++, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');

  
  debugPrint('Handling in background: ${message.messageId}');
}

Future<void> _setupCamera() async {
  final cameras = await availableCameras();
  _cameraController = CameraController(cameras[1], ResolutionPreset.ultraHigh);
  await _cameraController.initialize();
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final IPictureRepository apiRepo = ApiPictureRepository();
  final IPictureRepository mockRepo = MockPictureRepository();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (cameraProvider) =>
            CameraProvider(_cameraController, apiRepo)),
            // create: (cameraProvider) =>
            //     CameraProvider(_cameraController, mockRepo)),
      ],
      child: MaterialApp(
        title: 'Camera App',
        initialRoute: "/login",
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const MyHomePage()
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.camera)),
              Tab(icon: Icon(Icons.photo)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CameraScreen(),
            GalleryScreen(),
          ],
        ),
      ),
    );
  }
}
