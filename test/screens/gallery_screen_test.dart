import 'package:camera/camera.dart';
import 'package:camera_app/interfaces/Camera_app_db_inteface.dart';
import 'package:camera_app/providers/camera_provider.dart';
import 'package:camera_app/providers/repositories/MockRepo.dart';
import 'package:camera_app/providers/repositories/PictureRepo.dart';
import 'package:camera_app/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../providers/camera_provider_tests.dart';

class MockCameraDescription extends Mock implements CameraDescription {}

class MockCameraController extends Mock implements CameraController {
  @override
  var description = MockCameraDescription();
  @override
  Future<void> initialize() {
    return Future.value();
  }
}

void main() {
  late MockCameraController mockCameraController;
  late IPictureRepository repo;
  late CameraProvider cameraProvider;




  setUp(() {
    mockCameraController = MockCameraController();

    repo = ApiPictureRepository();

    cameraProvider = CameraProvider(mockCameraController, repo);
  });
  group("testing custom widget to make sure the correct image is shown", () {
    // 🡅🡆🡇🡇🡇🦅🦅🦅🦅

    testWidgets('CameraScreen displays CameraPreview when API is connected',
        (WidgetTester tester) async {
      // Provide the mockCameraProvider to the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CameraProvider>(
            create: (_) => cameraProvider,
            child: const CameraScreen(),
          ),
        ),
      );

      // Verify the CameraPreview is displayed
      expect(find.byType(CameraPreview), findsOneWidget);
      expect(find.byKey(const Key("CameraPreview")), findsOneWidget);
      expect(find.byType(CircularProgressIndicator),
          findsNothing); // Since API is connected
    });
  });
}
