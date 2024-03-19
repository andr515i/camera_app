import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:camera_app/interfaces/Camera_app_db_inteface.dart';
import 'package:flutter/foundation.dart';

class CameraProvider extends ChangeNotifier {
  late final CameraController _cameraController;

  bool isApiConnected = false;

  final IPictureRepository _repository;

  //  constructor
  CameraProvider(this._cameraController, this._repository) {
    checkConnection();
    // start the connection checker isolate
  }

  CameraController get cameraController => _cameraController;

  Future<void> takePicture() async {
    checkConnection();
    final XFile picture = await _cameraController.takePicture();
    final pictureBytes = await picture.readAsBytes();
    int index = await getMaxPictureIndex() + 1;
    await savePicture(index, pictureBytes);
    // await loadAllPictures();
  }

  Future<void> savePicture(int index, Uint8List pictureBytes) async {
    _repository.savePicture(index, pictureBytes);
    notifyListeners();
  }

  Future<List<Uint8List>> loadAllPictures() async {
    return _repository.loadAllPictures();
  }

  FutureOr<int> getMaxPictureIndex() async {
    int maxIndex = 0;
    try {
      final allPictures = await loadAllPictures();

      for (final picture in allPictures) {
        maxIndex = max(maxIndex, picture.length);
      }
    } catch (e) {
      debugPrint('something went wrong. \n$e');
    }

    return maxIndex;
  }

  Future<void> checkConnection() async {
    isApiConnected = await _repository.checkConnection();

    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    await _repository.login(username, password);

    notifyListeners();
  }

  void startIsolate() async {
    await _repository.handleResponse(200);

    await _repository.handleResponse(201);

    await _repository.handleResponse(401);

    await _repository.handleResponse(720);

  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
