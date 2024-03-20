import 'dart:isolate';

import 'package:camera_app/interfaces/camera_app_db_interface.dart';
import 'package:camera_app/models/login.dart';
import 'package:flutter/foundation.dart';

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
    return true;
  }

  // normally, you would check up on a database for the given usernames, and then further check their passwords or something of the like, however im just gonna simulate a very simple login function
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

  // This function will run in a separate isolate.
  void _checkHttpStatusCode(Map<String, dynamic> isolateData) {
    final sendPort = isolateData['sendPort'];
    final statusCode = isolateData['statusCode'];

    String statusMessage;
    switch (statusCode) {
      case 200:
        statusMessage = 'Response status code: 200 - OK';
        break;
      case 201:
        statusMessage = 'Response status code: 201 - Created';
        break;
      case 204:
        statusMessage = 'Response status code: 204 - No Content';
        break;
      case 400:
        statusMessage = 'Response status code: 400 - Bad Request';
        break;
      case 401:
        statusMessage = 'Response status code: 401 - Unauthorized';
        break;
      case 403:
        statusMessage = 'Response status code: 403 - Forbidden';
        break;
      case 404:
        statusMessage = 'Response status code: 404 - Not Found';
        break;
      case 500:
        statusMessage = 'Response status code: 500 - Internal Server Error';
        break;
      case 502:
        statusMessage = 'Response status code: 502 - Bad Gateway';
        break;
      case 503:
        statusMessage = 'Response status code: 503 - Service Unavailable';
        break;
      default:
        statusMessage = 'Response status code: $statusCode';
        break;
    }

    // Send the status message back to the main isolate.
    sendPort.send(statusMessage);
  }

  Future<void> handleResponse(int statusCode) async {
    // Create a ReceivePort to receive messages from the isolate.
    final receivePort = ReceivePort();

    // Start the isolate.
    await Isolate.spawn(
      _checkHttpStatusCode,
      {
        'sendPort': receivePort.sendPort,
        'statusCode': statusCode,
      },
    );

    // Receive the status message from the isolate.
    final statusMessage = await receivePort.first;

    debugPrint(statusMessage);
  }


  
  @override
  Future<void> sendNotification() {
    // TODO: implement sendNotification
    throw UnimplementedError();
  }
}
