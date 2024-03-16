import 'package:camera_app/interfaces/Camera_app_db_inteface.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiPictureRepository implements IPictureRepository {

  final String _apiUrl = 'http://10.0.2.2:5275/api/PictureStorage';

  int index = 0;

  bool isApiConnected = false;

  @override
  Future<List<Uint8List>> loadAllPictures() async {
    // Return a list of mock data
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
          pictures.add(base64Decode(pictureData)); // Convert from base64 string
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
     // Save the picture to the api

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

  // compute example 2  // TODO: implement
   Uint8List decodePictureData(String pictureData) {
    if (pictureData.isNotEmpty) {
      return base64Decode(pictureData);
    } else {
      debugPrint('Empty picture received from the API');
      return Uint8List(0); // Return an empty list or handle the case appropriately
    }
  }
}
