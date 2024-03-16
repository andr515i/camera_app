import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:camera_app/interfaces/Camera_app_db_inteface.dart';
import 'package:flutter/foundation.dart';

class CameraProvider extends ChangeNotifier {
  late CameraController _cameraController;

  bool isApiConnected = false;

  final IPictureRepository _repository;

  late Isolate _isolate;

  late ReceivePort _receivePort;

  //  constructor
  CameraProvider(this._cameraController, this._repository) {
    _cameraController.initialize();
    _cameraController = _cameraController;
    checkConnection();
    // start the connection checker isolate
    // _startIsolate();
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





  

// void _startIsolate() async {
//   _receivePort = ReceivePort();
//   _isolate = await Isolate.spawn(checkConnectionIsolate, [_receivePort.sendPort], onExit: _receivePort.sendPort);
//   SendPort _isolateSendPort = _receivePort.sendPort;
//   _receivePort.listen((message) {
//     if (message is bool) {
//       isApiConnected = message;
//       notifyListeners();
//     }
//   });

//   // Send the API URL to the isolate after it's been initialized
//   _isolateSendPort.send('http://10.0.2.2:5275/api/PictureStorage/Ping');
// }


// // This is the entry point for your isolate.
// void checkConnectionIsolate(List<dynamic> args) async {
//   final ReceivePort receivePort = ReceivePort();
//   SendPort sendPort = args[0];
//   sendPort.send(receivePort.sendPort);
//   String apiUrl = await receivePort.first; // Wait for the apiUrl

//   // Your connection checking logic here, apiUrl should be a simple String
//   try {
//     final client = http.Client();
//     // Replace 'apiUrl' with the actual string of the API URL passed from the main thread.
//     final response = await client.get(Uri.parse(apiUrl));

//     // No reference to CameraProvider's state should exist here, just send back true or false
//     sendPort.send(response.statusCode == 200);
//   } catch (e) {
//     sendPort.send(false); // In case of exception, send back false
//   }
// }


  @override
  void dispose() {
    _receivePort.close();
    _isolate.kill();
    _cameraController.dispose();
    super.dispose();
  }
}
