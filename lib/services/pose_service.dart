import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class PoseDetectionResult {
  final String imagePath;
  final ui.Size imageSize;
  final List<Pose> poses;

  PoseDetectionResult({
    required this.imagePath,
    required this.imageSize,
    required this.poses,
  });
}

class PoseService {
  static Future<PoseDetectionResult> detectPoseFromVideoFrame(
    String videoPath, {
    int timeMs = 0,
  }) async {
    final thumbData = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 720,
      quality: 90,
      timeMs: timeMs,
    );

    if (thumbData == null) {
      print('PoseService: thumbnailData is null');
      throw Exception('動画のフレームを取得できませんでした。');
    }

    final tempDir = await getTemporaryDirectory();
    final outputFile = File(
      '${tempDir.path}/pose_frame_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await outputFile.writeAsBytes(thumbData);
    print(
      'PoseService: wrote thumbnail to ${outputFile.path} (${thumbData.length} bytes)',
    );

    final imageSize = await _decodeImageSize(thumbData);
    final inputImage = InputImage.fromFilePath(outputFile.path);
    print('PoseService: created InputImage from file ${outputFile.path}');

    final options = PoseDetectorOptions(mode: PoseDetectionMode.single);
    final detector = PoseDetector(options: options);
    try {
      print('PoseService: running detector.processImage...');
      final poses = await detector.processImage(inputImage);
      print('PoseService: detector returned ${poses.length} poses');
      detector.close();

      if (poses.isEmpty) {
        throw Exception('画像から姿勢を検出できませんでした。');
      }

      return PoseDetectionResult(
        imagePath: outputFile.path,
        imageSize: imageSize,
        poses: poses,
      );
    } catch (e, st) {
      print('PoseService: exception during pose detection: $e');
      print(st);
      detector.close();
      rethrow;
    }
  }

  static Future<ui.Size> _decodeImageSize(Uint8List bytes) async {
    final completer = Completer<ui.Size>();
    ui.decodeImageFromList(bytes, (image) {
      completer.complete(
        ui.Size(image.width.toDouble(), image.height.toDouble()),
      );
    });
    return completer.future;
  }

  /// Extracts a single frame from [videoPath] and returns a PoseDetectionResult
  /// with no poses. Useful for mock/preview scenarios where ML Kit is bypassed.
  static Future<PoseDetectionResult> extractFrameOnly(String videoPath) async {
    final thumbData = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 720,
      quality: 90,
      timeMs: 0,
    );

    if (thumbData == null) {
      throw Exception('動画のフレームを取得できませんでした。');
    }

    final tempDir = await getTemporaryDirectory();
    final outputFile = File(
      '${tempDir.path}/pose_frame_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await outputFile.writeAsBytes(thumbData);
    final imageSize = await _decodeImageSize(thumbData);

    return PoseDetectionResult(
      imagePath: outputFile.path,
      imageSize: imageSize,
      poses: [],
    );
  }
}
