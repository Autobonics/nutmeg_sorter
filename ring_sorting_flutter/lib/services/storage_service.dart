import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:ring_sorting_flutter/app/app.logger.dart';
import 'package:stacked/stacked.dart';
// import 'package:http/http.dart' as http;

class StorageService with ListenableServiceMixin {
  final log = getLogger('StorageService');
  // StorageService() {
  //   _uploadTaskController.addListener(() {
  //     notifyListeners();
  //   });
  // }

  final _storage = FirebaseStorage.instance;
  // final _uploadTaskController = StreamController<TaskSnapshot>();

  // Stream<TaskSnapshot> get uploadTaskStream => _uploadTaskController.stream;
  double _progress = 0;
  double get progress => _progress;

  Future<String> uploadFile(File file, String path) async {
    // final filePath = 'chats/${DateTime.now().millisecondsSinceEpoch}';
    final filePath = path;
    final reference = _storage.ref().child(filePath);
    final uploadTask = reference.putFile(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      // snapshot
      _progress = snapshot.bytesTransferred / snapshot.totalBytes * 100;
      notifyListeners();
      // return Text('${progress.toStringAsFixed(2)}%');
    });

    final snapshot = await uploadTask.whenComplete(() {});
    final url = await snapshot.ref.getDownloadURL();
    _progress = 0;
    notifyListeners();
    return url;
  }

  // Future deleteFile(String path) async {
  //   final Reference storageRef = _storage.ref().child(path);
  //   try {
  //     await storageRef.delete();
  //     log.i('File deleted successfully.');
  //   } catch (e) {
  //     log.i('Error deleting file: $e');
  //   }
  // }
  //
  // // Function to download a file from Firebase Storage
  // Future<File?> downloadFile(String url, String path, String format) async {
  //   final http.Response downloadData = await http.get(Uri.parse(url));
  //   final Directory systemTempDir = await getTemporaryDirectory();
  //   final File downloadToFile =
  //       File('${systemTempDir.path}/${path.split('/').last}.$format');
  //   await downloadToFile.writeAsBytes(downloadData.bodyBytes);
  //   // Directory appDocDir = await getApplicationDocumentsDirectory();
  //   // File downloadToFile = File('${appDocDir.path}/$path.$format');
  //   // try {
  //   //   await _storage.ref(path).writeToFile(downloadToFile);
  //   return downloadToFile;
  //   // } catch (e) {
  //   //   // e.g, e.code == 'canceled'
  //   //   log.e('Download error: $e');
  //   // }
  //   return null;
  // }
  //
  // Future deleteChatFiles(String id) async {
  //   log.i("Deleting chats files");
  //   await _storage.ref("chats/$id").listAll().then((value) {
  //     for (var element in value.items) {
  //       _storage.ref(element.fullPath).delete();
  //     }
  //   });
  // }
}
