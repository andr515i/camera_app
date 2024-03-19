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
    cameraProvider.checkConnection();
    if (cameraProvider.isApiConnected) {
      return Scaffold(
          body: Column(
        children: [
          Expanded(
              child: CameraPreview(
            cameraProvider.cameraController,
            child: Padding(
                padding: const EdgeInsets.all(25),
                key: const Key("CameraPreview"),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      key: const Key("TakePicture"),
                      onPressed: () async {
                        await cameraProvider.takePicture();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('picture taken')));
                      },
                      child: const Icon(Icons.camera),
                    ),
                  ],
                )),
          ))
        ],
      ));
    } else {
      cameraProvider.checkConnection();
      return const CircularProgressIndicator();
    }
  }
}
