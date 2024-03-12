// providers/picture_provider.dart
import 'package:flutter/material.dart';

class PictureProvider extends ChangeNotifier {
  final List<String> _pictures = [];

  List<String> get pictures => _pictures;

  void addPicture(String picturePath) {
    _pictures.add(picturePath);
    notifyListeners();
  }
}