import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:camera_app/interfaces/camera_app_db_interface.dart'; // Correct interface name if necessary
import 'package:flutter/foundation.dart';

// Provides functionalities related to camera operations and picture management.
class CameraProvider extends ChangeNotifier {
  late final CameraController
      _cameraController; // Controls camera actions and configurations.

  bool isApiConnected = false; // Flag to keep track of API connection status.

  final IPictureRepository
      _repository; // Interface for picture data management.

  // Constructor: Initializes the camera controller and repository.
  CameraProvider(this._cameraController, this._repository) {
    checkConnection(); // Checks the connection status when the provider is initialized.
  }

  // Getter to expose the private _cameraController.
  CameraController get cameraController => _cameraController;

  // Captures a picture, saves it, and updates the picture index.
  Future<void> takePicture() async {
    checkConnection(); // Ensures the API is connected before taking a picture.
    final XFile picture = await _cameraController.takePicture();
    final pictureBytes = await picture.readAsBytes();
    int index = await getMaxPictureIndex() +
        1; // Calculate the new index for the new picture.
    await savePicture(index,
        pictureBytes); // Saves the new picture using the calculated index.
  }

  // Saves a picture byte array to the repository.
  Future<void> savePicture(int index, Uint8List pictureBytes) async {
    _repository.savePicture(index, pictureBytes);
    notifyListeners(); // Notifies listeners that the picture list may have changed.
  }

  // Loads all pictures from the repository.
  Future<List<Uint8List>> loadAllPictures() async {
    return _repository.loadAllPictures();
  }

  // Retrieves the highest picture index from the stored pictures.
  FutureOr<int> getMaxPictureIndex() async {
    int maxIndex = 0;
    try {
      final allPictures = await loadAllPictures();
      for (final picture in allPictures) {
        maxIndex = max(
            maxIndex,
            picture
                .length); // Assumes 'length' reflects the picture's index. May need adjustment.
      }
    } catch (e) {
      debugPrint('Something went wrong: $e');
    }
    return maxIndex;
  }

  // Checks and updates the API connection status.
  Future<void> checkConnection() async {
    isApiConnected = await _repository.checkConnection();
    notifyListeners(); // Updates listeners with the new API connection status.
  }

  // Handles user login through the repository.
  Future<void> login(String username, String password) async {
    await _repository.login(username, password);
    notifyListeners(); // Updates any listeners upon a successful login.
  }

  // Starts an isolate for handling specific tasks - functionality not fully implemented here.
  // This seems like a placeholder for future functionality as there's no isolate-related logic.
  Future<void> startIsolate() async {
    // Placeholder for future functionality - modify based on actual use-case.
    await _repository.handleResponse(200);
    await _repository.handleResponse(201);
    await _repository.handleResponse(401);
    await _repository.handleResponse(720);
  }

  Future<void> sendNotification() async {
     debugPrint('start');
    await _repository.sendNotification();
  }

  // Cleans up the controller when the provider is disposed.
  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
