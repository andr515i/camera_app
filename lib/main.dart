// main.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:camera_app/screens/camera_screen.dart';
import 'package:camera_app/screens/gallery_screen.dart';
import 'package:provider/provider.dart';
import 'package:camera_app/providers/camera_provider.dart';

late CameraController _cameraController;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('main called');

  final cameras = await availableCameras();

  _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
  
  await _cameraController.initialize();

  runApp(MyApp(
    cameras: cameras,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.cameras, super.key});
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => CameraProvider(_cameraController)),
      ],
      child: MaterialApp(
        title: 'Camera App',
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
          title: const Text('Camera App'),
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
