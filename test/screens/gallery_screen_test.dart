import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockCameraDescription extends Mock implements CameraDescription {}

class MockCameraController extends Mock implements CameraController {
  @override
  var description = MockCameraDescription();

  @override
  Widget buildPreview() {
    // Just return a placeholder for testing purposes, instead of the live camera feed (even the fake one)
    return Container(color: Colors.black);
  }

  // Add a mock CameraValue.
  @override
  CameraValue get value => CameraValue(
        isInitialized: true, // Set to true to mimic an initialized camera
        previewSize: const Size(1280, 720),
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
        exposurePointSupported: true,
        focusMode: FocusMode.auto,
        exposureMode: ExposureMode.auto,
        flashMode: FlashMode.off,
        isRecordingPaused: true,
        focusPointSupported: true,
        deviceOrientation: DeviceOrientation.portraitUp,
        description: description,
      );

  @override
  Future<void> initialize() {
    return Future.value();
  }
}

class test extends StatelessWidget {
  late MockCameraController mockCameraController;
  test({super.key, required this.mockCameraController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: CameraPreview(
      mockCameraController,
      key: const Key("CameraPreview"),
    )));
  }
}

void main() {
  late MockCameraController mockCameraController;
  setUp(() {
    mockCameraController = MockCameraController();
  });
  group("testing custom widget to make sure the correct image is shown", () {
    // 🡅🡆🡇🡇🡇🦅🦅🦅🦅

    testWidgets('CameraScreen displays CameraPreview when API is connected🡅🡆🡇🡇🡇🦅🦅🦅🦅',
        (WidgetTester tester) async {
      await tester.pumpWidget(test(mockCameraController: mockCameraController));

      // Verify the CameraPreview is displayed
      expect(find.byType(CameraPreview), findsOneWidget);
      expect(find.byKey(const Key("CameraPreview")), findsOneWidget);
      expect(find.byType(CircularProgressIndicator),
          findsNothing); // Since API is connected
    });
  });
}
