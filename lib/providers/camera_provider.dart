import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CameraProvider extends ChangeNotifier {
  late CameraController _cameraController;

  final _apiUrl = 'http://10.0.2.2:5275/api/PictureStorage';

  bool isApiConnected = false;

  final http.Client _client = http.Client();

  int index = 0;

  late Isolate _isolate;  

  late ReceivePort _receivePort;

  CameraProvider(CameraController cameraController) {
    // constructor

    cameraController.initialize();

    _cameraController = cameraController;

    checkConnection(_client);

    // start the connection checker isolate
     _startIsolate();
     
  }

  CameraController get cameraController => _cameraController;

  Future<void> takePicture() async {
    checkConnection(_client);
    final XFile picture = await _cameraController.takePicture();
    final pictureBytes = await picture.readAsBytes();
    int index = await getMaxPictureIndex() + 1;
    await savePicture(index, pictureBytes);
    // await loadAllPictures();
  }

  Future<void> savePicture(int index, Uint8List pictureBytes) async {
    var client = http.Client();
    try {
      index++;
      debugPrint(
          '\n-----------------------------------------------------\nsaving picture\n-----------------------------------------------------\n');
      // Convert to base64 string
      final base64Image = compute(encodePictureData, pictureBytes);

      var response = await client.post(
        Uri.parse('$_apiUrl/SavePicture'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(base64Image), // Send as JSON
      );

      client.close();
      if (response.statusCode != 200) {
        throw Exception('Failed to save picture: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error saving picture: $e');
    } finally {
      client.close();
    }

    notifyListeners();
  }

  Future<List<Uint8List>> loadAllPictures() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/GetPicture'));

      if (response.statusCode != 200) {
        throw Exception('Failed to load pictures: ${response.statusCode}');
      }

      final picturesData = jsonDecode(response.body);
      final pictures = <Uint8List>[];

      for (final pictureData in picturesData) {
        if (pictureData.isNotEmpty) {
          // var pic = await compute(decodePictureData, pictureData);
          pictures.add(
              decodePictureData(pictureData)); // Convert from base64 string
        } else {
          debugPrint('Empty picture received from the API');
        }
      }

      notifyListeners();
      return pictures;
    } catch (e) {
      debugPrint('Error loading pictures: $e');
      rethrow;
    }
  }

  Uint8List decodePictureData(String pictureData) {
    if (pictureData.isNotEmpty) {
      return base64Decode(pictureData);
    } else {
      debugPrint('Empty picture received from the API');
      return Uint8List(
          0); // Return an empty list or handle the case appropriately
    }
  }

  String encodePictureData(Uint8List pictureData) {
    return base64Encode(pictureData);
  }

  FutureOr<int> getMaxPictureIndex() async {
    int maxIndex = 0;
    try {
      final allPictures = await loadAllPictures();

      for (final picture in allPictures) {
        maxIndex = max(index, picture.length);
      }
    } catch (e) {
      maxIndex = index;
    }

    return maxIndex;
  }

  Future<bool> checkConnection(http.Client client) async {
    try {
      final response = await client.get(Uri.parse('$_apiUrl/Ping'));

      if (response.statusCode == 200) {
        isApiConnected = true;
        return true;
      } else {
        isApiConnected = false;
        return false;
      }
    } catch (e) {
      isApiConnected = false;
    }
    debugPrint("api connected: $isApiConnected");

    notifyListeners();
    return false;
  }
  
  void _startIsolate() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(checkConnectionIsolate, _receivePort.sendPort);

    //listen for messages fromt he isolate

    _receivePort.listen((message) {
      if (message is bool) {
        isApiConnected = message;
      }
      notifyListeners();
    });

    // return isApiConnected;

  }

  void checkConnectionIsolate(SendPort sendPort) async {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

try {
  final client = http.Client();
  final response = await client.get(Uri.parse('$_apiUrl/Ping'));

  if (response.statusCode == 200) {
    isApiConnected = true;
  } else {
    isApiConnected = false;
  }

  sendPort.send(isApiConnected);


}
catch (e) {
  isApiConnected = false;
  debugPrint('error: $e');
  sendPort.send(isApiConnected);
}

  }

  @override
  void dispose() {
    _receivePort.close();
    _isolate.kill();
    _cameraController.dispose();
    super.dispose();
  }
}
