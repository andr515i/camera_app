import 'package:camera/camera.dart';
import 'package:camera_app/providers/camera_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera_provider_tests.mocks.dart';

// Mock CameraController
class MockCameraDescription extends Mock implements CameraDescription {}

class MockCameraController extends Mock implements CameraController {
  var description = MockCameraDescription();
  @override
  Future<void> initialize() {
    return Future.value();
  }
}

@GenerateMocks([http.Client])
void main() {
  group("testing api connectivity", () {
    late MockCameraController mockCameraController;
    late CameraProvider cameraProvider;
    setUp(() {
      mockCameraController = MockCameraController();
      // Define behavior for initialize method
      // when(mockCameraController.initialize()).thenAnswer((_) async => Future.value());
      // Pass the mock to CameraProvider
      cameraProvider = CameraProvider(mockCameraController);
    });

    test("test connection is true", () async {
      // initialize a mock client
      final client = MyMockClient(); // mock client made with mockito

      when(client.get(
        Uri.parse('http://10.0.2.2:5275/api/PictureStorage/Ping'),
        headers:
            anyNamed('headers'), 
      )).thenAnswer((_) async => http.Response('Success', 200));
      // Verify that initialize method is called
      await cameraProvider.checkConnection(client);

      expect(cameraProvider.checkConnection(client), completion(isTrue));
    });
    test("test connection using isolates", () {
      
    });
  });
}
