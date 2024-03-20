import 'dart:async';
import 'package:camera/camera.dart';
import 'package:camera_app/firebase_options.dart';
import 'package:camera_app/interfaces/camera_app_db_interface.dart';
import 'package:camera_app/providers/repositories/mockRepo.dart';
import 'package:camera_app/providers/repositories/pictureRepo.dart';
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

// initialize the camera controller used for the provider to take pictures.
late CameraController _cameraController;

final NotificationService _notificationService =
    NotificationService(); // for notifications in the foreground mainly
var index = 0; // notification id, gets incremented by 1 every notification

Future<void> main() async {
  // app wont work if the widgets havent been initialized before starting MyApp
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions
          .currentPlatform); // initialize firebase app with default platform specific options.

  // debugPrint(await FirebaseMessaging.instance.getToken()); // token used to send notifications from the firebase console
  _notificationService
      .requestNotificationPermissions(); //request permissions to take pictures, use sound, see live camera and some other things.
  _notificationService.firebaseInit(); //

  FirebaseMessaging.onBackgroundMessage(
      _backgroundHandler); // handle background messages.

      print('token: ${await FirebaseMessaging.instance.getToken()}');

  await _setupCamera(); // setup the camera

  runApp(MyApp()); // and start the app
}

// entry point for background messages. custom notifications because im awesome. does have a slight effect of making 2 notifications when recieving from api
@pragma(
  'vm:entry-point',
)
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
  await plugin.show(100 + index++, null, null, notificationDetails,
      payload: 'item x');

  debugPrint('Handling in background: ${message.messageId}');
}

/// setup the camera for the cameracontroller.
/// also initializes the cameracontroller
Future<void> _setupCamera() async {
  final cameras = await availableCameras();
  _cameraController = CameraController(cameras[1], ResolutionPreset.ultraHigh);
  await _cameraController.initialize();
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  // initialize the repo's that will be used. whichever one is unsed will be removed by tree shaking.
  final IPictureRepository apiRepo = ApiPictureRepository();
  final IPictureRepository mockRepo = MockPictureRepository();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // create the providers used (change if api is connected or not.) possible future upgrade would be to apply the mock repo incase there is no connection to the api, and then seamlessly switch them out when connection can be made.
        ChangeNotifierProvider(
            // create: (cameraProvider) =>
            //     CameraProvider(_cameraController, apiRepo)),
            create: (cameraProvider) =>
                CameraProvider(_cameraController, mockRepo)),
      ],
      child: MaterialApp(
        title: 'Camera App',
        initialRoute: "/login",
        routes: {
          '/login': (context) =>
              const LoginScreen(), // start screen is login screen.
          '/home': (context) =>
              const MyHomePage() // but the actual home page is MyHomePage (which is a tab view starting with the camera screen)
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
              Tab(icon: Icon(Icons.camera)), // goto camera
              Tab(icon: Icon(Icons.photo)), // goto gallery
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CameraScreen(), // show camera
            GalleryScreen(), // show gallery
          ],
        ),
      ),
    );
  }
}
