import 'package:camera_app/screens/gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera_app/main.dart' as app;
import 'package:patrol/patrol.dart'; // Import your main.dart file

void main() {

  group('Camera App Integration Tests', () {
    patrolTest("Full App Test", (tester) async {
      app.main(); // Start your app
      await tester.pumpAndSettle(); // Wait for everything to load

      try {
        tester.native.grantPermissionWhenInUse();
        await tester.pumpAndSettle();
        tester.native.grantPermissionWhenInUse();
      } catch (e) {
        debugPrint("no permissions needed...");
      }

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

      // Perform drag and drop test
      // Note: Adjust the logic below based on your app's specific drag-and-drop implementation
      final firstImage = find.byType(MyDraggablePicture).first;
      final dragTarget = find.byType(DragTarget).first;

// await tester.dragUntilVisible(
//   finder: firstImage, // The widget to drag
//   view: targetView,   // The widget you want to be visible after dragging
//   moveStep: const Offset(0, -300), // The step to move per gesture tick. Adjust as necessary.
//       await tester.pumpAndSettle();

//       // Verify the picture is accepted by the drag target
//       // This depends on how you visually indicate a successful drag-and-drop in your app
//       // For example, if the drag target changes color, you can check for that
//       // Or, if it displays the dragged image, you can check for the presence of two images now
//       expect(dragTarget,
//           findsOneWidget); // Replace 'displaysImage' with actual verification logic
    });
  });
}
