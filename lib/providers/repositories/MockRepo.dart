import 'package:camera_app/interfaces/Camera_app_db_inteface.dart';
import 'dart:typed_data';

class MockPictureRepository implements IPictureRepository {
  final List<Uint8List> _pictures = [];

  @override
  Future<List<Uint8List>> loadAllPictures() async {
    // Return a list of mock data
    return _pictures;
  }

  @override
  Future<void> savePicture(int index, Uint8List pictureBytes) async {
    // Save the picture in the local mock list
    _pictures.add(pictureBytes);
  }

  @override
  Future<int> getMaxPictureIndex() async {
    // Return the highest index in the mock list
    return _pictures.length;
  }

  @override
  Future<bool> checkConnection() async {
    // Always return true or false based on testing needs
    return true;
  }
}
