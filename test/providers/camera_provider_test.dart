import 'package:camera/camera.dart';
import 'package:camera_app/interfaces/Camera_app_db_inteface.dart';
import 'package:camera_app/providers/camera_provider.dart';
import 'package:camera_app/providers/repositories/PictureRepo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera_provider_test.mocks.dart';

// Mock CameraController
class MockCameraDescription extends Mock implements CameraDescription {}

class MockCameraController extends Mock implements CameraController {
  @override
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
    late IPictureRepository repo;
    late CameraProvider cameraProvider;
    setUp(() {
      mockCameraController = MockCameraController();
      
      repo = ApiPictureRepository();
      
      cameraProvider = CameraProvider(mockCameraController, repo);
    });

    test("test connection is true", () async {
      // initialize a mock client
      final client = MyMockClient(); // mock client made with mockito

      when(client.get(
        Uri.parse('http://10.0.2.2:5275/api/PictureStorage/Ping'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Success', 200));
      // Verify that initialize method is called

      when(cameraProvider
          .checkConnection()
          .then((value) => completes));

      // await cameraProvider.checkConnection();

      expect(cameraProvider.checkConnection(), completes); // passes if checkConnection doesnt return an error
    });
    // test("test connection using isolates", () {});
  });
}
