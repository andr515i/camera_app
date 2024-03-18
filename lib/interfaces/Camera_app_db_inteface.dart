import 'dart:typed_data';

abstract class IPictureRepository {
  Future<List<Uint8List>> loadAllPictures();
  Future<void> savePicture(int index, Uint8List pictureBytes);
  Future<int> getMaxPictureIndex();
  Future<bool> checkConnection();
  Future<void> login(String username, String password);
}
