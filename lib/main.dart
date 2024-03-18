// main.dart
import 'package:camera/camera.dart';
import 'package:camera_app/firebase_options.dart';
import 'package:camera_app/interfaces/Camera_app_db_inteface.dart';
import 'package:camera_app/providers/repositories/MockRepo.dart';
import 'package:camera_app/providers/repositories/PictureRepo.dart';
import 'package:camera_app/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:camera_app/screens/camera_screen.dart';
import 'package:camera_app/screens/gallery_screen.dart';
import 'package:provider/provider.dart';
import 'package:camera_app/providers/camera_provider.dart';

late CameraController _cameraController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(await FirebaseMessaging.instance.getToken());
  await _setupCamera();

  runApp(MyApp());
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
            // create: (cameraProvider) => CameraProvider(_cameraController, apiRepo)),
            create: (cameraProvider) =>
                CameraProvider(_cameraController, mockRepo)),
      ],
      child: MaterialApp(
        title: 'Camera App',
        initialRoute: "/login",
        routes: {
          '/login':(context) => const LoginScreen(),
          '/home':(context) => const MyHomePage()
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
          // title: const Text('Camera App'),
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
