import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:ring_sorting_flutter/app/app.logger.dart';

class ImageProcessingService {
  final log = getLogger('ImageProcessingService');

  Future<File> getCroppedImageOfRing(String path) async {
    int width = 300;
    return await cropImage(path, path, 0, 0, width, width);
  }

  //Cropping image in different thread to avoid freezing.
  Future<File> cropImage(String inputPath, String outputPath, int x, int y,
      int width, int height) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_cropImageInIsolate, {
      'inputPath': inputPath,
      'outputPath': outputPath,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'sendPort': receivePort.sendPort,
    });
    final croppedFilePath = await receivePort.first;
    return File(croppedFilePath);
  }

  void _cropImageInIsolate(dynamic message) {
    final inputPath = message['inputPath'];
    final outputPath = message['outputPath'];
    final x = message['x'];
    final y = message['y'];
    final width = message['width'];
    final height = message['height'];
    final sendPort = message['sendPort'];

    File imageFile = File(inputPath);
    Uint8List bytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      log.i("Cropping..");
      img.Image resizedImage = img.copyResize(image, width: width);
      img.Image croppedImage =
          img.copyCrop(resizedImage, x: x, y: y, width: width, height: height);
      File croppedFile = File(outputPath);
      croppedFile.writeAsBytesSync(img.encodeJpg(croppedImage));
      sendPort.send(croppedFile.path);
    } else {
      sendPort.send(imageFile.path);
    }
  }

// Example usage:
//   cropImage('path/to/input/image.jpg', 'path/to/output/croppedImage.jpg', 0, 0, 100, 100).then((File croppedFile) {
//   print('Image cropped successfully: ${croppedFile.path}');
//   });
}
