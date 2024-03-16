import 'package:camera/camera.dart';
import 'package:camera_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late var cameraDescription;
 setUp(() async {
    cameraDescription = await availableCameras();
  });

  group("pictures and dragtargets", () {
    testWidgets("test picture count is 1 less than dragtarget count", ((tester) async {
      await tester.pumpWidget(MyApp(cameras: cameraDescription),const  Duration(seconds: 25));

      expect(tester.tap(find.byKey(const Key("CameraPreview"))), findsOneWidget);

    }));
  });
}
