import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:camera_app/providers/camera_provider.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    // Access the CameraProvider for managing camera states and operations.
    final cameraProvider = Provider.of<CameraProvider>(context);
    // Check if the application has access to the camera and API.
    cameraProvider.checkConnection();

    // Display the camera preview if the API is connected.
    if (cameraProvider.isApiConnected) {
      return Scaffold(
        body: Column(
          children: [
            // Use Expanded to make the CameraPreview fill the screen.
            Expanded(
              child: CameraPreview(
                cameraProvider.cameraController, // Provide the CameraController from the CameraProvider.
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  key: const Key("CameraPreview"), // Key used for identifying the camera preview widget.
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end, // Aligns the button to the bottom of the widget.
                    mainAxisAlignment: MainAxisAlignment.center, // Centers the button horizontally.
                    children: [
                      // Floating action button to take pictures.
                      FloatingActionButton(
                        key: const Key("TakePicture"), // Key used for identifying the take picture button.
                        onPressed: () async {
                          await cameraProvider.takePicture(); // Trigger picture taking through CameraProvider.
                          // Show a snackbar notification when a picture is taken.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Picture taken')),
                          );
                        },
                        child: const Icon(Icons.camera), // Icon displayed inside the button.
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // If the API is not connected, attempt to check the connection again.
      cameraProvider.checkConnection();
      // Display a CircularProgressIndicator while checking the connection.
      return const Center(child: CircularProgressIndicator());
    }
  }
}
