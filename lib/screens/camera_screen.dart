// screens/camera_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:camera_app/providers/camera_provider.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);

    return Scaffold(
      body: CameraPreview(cameraProvider.cameraController),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          cameraProvider.takePicture();
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
