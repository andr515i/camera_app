import 'dart:html';
import 'dart:isolate';

import 'package:camera_app/interfaces/Camera_app_db_inteface.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiPictureRepository implements IPictureRepository {
  final String _apiUrl = 'http://10.0.2.2:5275/api/PictureStorage';

  int index = 0;

  bool isApiConnected = false;

  String tokenString = "";

  late Isolate _isolate;

  late ReceivePort _receivePort;

  @override
  Future<List<Uint8List>> loadAllPictures() async {
    // Return a list of actual data (can be empty)
    try {
      final response = await http.get(Uri.parse('$_apiUrl/GetPicture'),
          headers: {'Authorization': 'Bearer $tokenString'});

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load pictures: ${jsonDecode(response.body)}');
      }

      final picturesData = jsonDecode(response.body);
      final pictures = <Uint8List>[];

      for (final pictureData in picturesData) {
        if (pictureData.isNotEmpty) {
          // var pic = await compute(decodePictureData, pictureData); //compute decode data
          pictures.add(base64Decode(
              pictureData)); // Convert from base64 string into string picture list
        } else {
          debugPrint('Empty picture received from the API');
        }
      }

      return pictures;
    } catch (e) {
      debugPrint('Error loading pictures: $e');
      rethrow;
    }
  }

  @override
  Future<void> savePicture(int index, Uint8List pictureBytes) async {
    // Save the picture and send it to the api

    var client = http.Client();
    try {
      index++;
      debugPrint(
          '\n-----------------------------------------------------\nsaving picture\n-----------------------------------------------------\n');
      // Convert to base64 string
      final base64Image = await compute(encodePictureData, pictureBytes);
      // final base64Image = base64Encode(pictureBytes);
      var response = await client.post(
        Uri.parse('$_apiUrl/SavePicture'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenString'
        },
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
  }

  @override
  Future<int> getMaxPictureIndex() async {
    // Return the index count of all pictures.
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

  @override
  Future<bool> checkConnection() async {
    // check if connection to api can be established
    try {
      final response = await http.get(Uri.parse('$_apiUrl/Ping'));

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

    return false;
  }

  //compute example 1
  String encodePictureData(Uint8List pictureData) {
    return base64Encode(pictureData);
  }

  // compute example 2
  // TODO: implement
  Uint8List decodePictureData(String pictureData) {
    if (pictureData.isNotEmpty) {
      return base64Decode(pictureData);
    } else {
      debugPrint('Empty picture received from the API');
      return Uint8List(
          0); // Return an empty list or handle the case appropriately
    }
  }

// normally, you would check up on a database for the given usernames, and then further check their passwords or something of the like, however im just gonna simulate a very simple login function
  @override
  Future<void> login(String username, String password) async {
    // authenticate login up to the api and generate jwt token
    final Map<String, String> user = {
      'username': username,
      'passwordEncrypted': password
    };

    final response = await http.post(
      Uri.parse('$_apiUrl/Login'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user),
    );
    debugPrint('response code for login: ${response.statusCode}');
    if (response.statusCode == 200) {
      tokenString = jsonDecode(response.body)['token'];
      debugPrint('bearer: $tokenString');
    } else {
      throw Exception('Failed to login');
    }
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

  @override
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
  Future<void> sendNotification() async{
    final response = await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"), headers: {
      "Content-Type": "application/json",
"Authorization": "key=<Server_key>"
    });
  }
}
