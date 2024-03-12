import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CameraProvider extends ChangeNotifier {
  late CameraController _cameraController;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late List<XFile?> pictures;

  CameraProvider(CameraController cameraController) {
    _cameraController = cameraController;
    pictures = List<XFile?>.empty(growable: true);
    debugPrint('CameraProvider created');
  }

  CameraController get cameraController => _cameraController;

  Future<void> takePicture() async {
    final XFile picture = await _cameraController.takePicture();
    pictures.add(picture);
    final pictureBytes = await picture.readAsBytes();
    int index = await getMaxPictureIndex() + 1;
    await savePicture(index, pictureBytes);
    await loadAllPictures();
  }

  Future<void> savePicture(int index, Uint8List pictureBytes) async {
    final String pictureData = base64Encode(pictureBytes);
    await _storage.write(key: 'picture_$index', value: pictureData);
    notifyListeners();
    debugPrint('Picture saved with index: $index');
  }

  Future<Uint8List> loadPicture(int index) async {
    final String? pictureData = await _storage.read(key: 'picture_$index');
    if (pictureData == null) {
      throw Exception('Picture not found with index: $index');
    }
    final pictureBytes = base64Decode(pictureData);
    notifyListeners();
    return pictureBytes;
  }

  Future<List<Uint8List>> loadAllPictures() async {
    final allKeys = await _storage.readAll();
    final List<Uint8List> picturesRaw = [];
    for (String key in allKeys.keys) {
      final pictureBytes = await loadPicture(int.tryParse(key.substring(8))!);
      picturesRaw.add(pictureBytes);
        }
    print('Loaded pictures: $picturesRaw');
    notifyListeners();
    return picturesRaw;
  }

  Future<int> getPictureCount() async {
    final allKeys = await _storage.readAll();
    debugPrint('Found ${allKeys.length} keys');
    return allKeys.keys.where((key) => key.startsWith('picture_')).length;
  }

  Future<int> getMaxPictureIndex() async {
    final allKeys = await _storage.readAll();
    int maxIndex = 0;
    for (String key in allKeys.keys) {
      final index = int.tryParse(key.substring(8));
      if (index != null && index > maxIndex) {
        maxIndex = index;
      }
    }
    notifyListeners();
    debugPrint('Max picture index: $maxIndex');
    return maxIndex;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
    debugPrint('CameraProvider disposed');
  }
}
