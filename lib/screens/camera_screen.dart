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
    cameraProvider.isApiConnected
        ? const SizedBox.shrink()
        : const CircularProgressIndicator();
    return Scaffold(
      body: CameraPreview(cameraProvider.cameraController,
          key: const Key("CameraPreview")),
      floatingActionButton: FloatingActionButton(
        key: const Key("TakePicture"),
        onPressed: () {
          cameraProvider.takePicture();
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
