import 'package:camera_app/interfaces/Camera_app_db_inteface.dart';
import 'package:camera_app/models/login.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockPictureRepository implements IPictureRepository {
  final List<Uint8List> _pictures = [];

  final storage = const FlutterSecureStorage();

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
    return false;
  }
  
  @override
  Future<void> login(String username, String password) async {
    LoginModel user = LoginModel(username: "", passwordEncrypted: "");
    if (username.isNotEmpty && password.isNotEmpty) {
      user = LoginModel(username: username, passwordEncrypted: password);
      debugPrint('user created: $user');
      return;
    }
    // should throw error to indicate failure.
    throw Exception("user creation failed.");

  }
}
