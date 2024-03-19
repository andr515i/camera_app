import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera_app/main.dart' as app;
import 'package:patrol/patrol.dart'; 

void main() {
  group('Camera App Integration Tests', () {
    patrolTest("Full App Test", (tester) async {
      
      app.main(); // Start your app
      await tester.pumpAndSettle(); // Wait for everything to load

      // Find the camera button and take a picture
      final cameraButtonFinder = find.byKey(const Key("TakePicture"));
      expect(cameraButtonFinder, findsOneWidget);
      await tester.tap(cameraButtonFinder);
      await tester.pumpAndSettle(); // Wait for picture to be taken

      // Switch to the Gallery tab
      final galleryTabFinder = find.byIcon(Icons.photo);
      await tester.tap(galleryTabFinder);
      await tester.pumpAndSettle(); // Wait for gallery to load

      // Check if the image appears in the gallery
      final imageFinder =
          find.byType(Image); // Adjust if necessary to match your widget types
      expect(imageFinder, findsWidgets);


    });
  });
}
