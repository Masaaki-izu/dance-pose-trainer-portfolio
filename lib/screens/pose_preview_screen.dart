import 'dart:io';

import 'package:flutter/material.dart';
import '../services/pose_service.dart';
import '../widgets/pose_painter.dart';
import '../widgets/mock_pose_painter.dart';

class PosePreviewScreen extends StatelessWidget {
  final String videoPath;
  final bool useMock;
  const PosePreviewScreen({super.key, required this.videoPath, this.useMock = false});

  @override
  Widget build(BuildContext context) {
    if (useMock) {
      // debug log to confirm mock mode
      // ignore: avoid_print
      print('PosePreviewScreen: running in MOCK mode for $videoPath');
    }
    return Scaffold(
      appBar: AppBar(title: const Text('ポーズプレビュー')),
      body: FutureBuilder<PoseDetectionResult>(
        future: useMock
            ? PoseService.extractFrameOnly(videoPath)
            : PoseService.detectPoseFromVideoFrame(videoPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('ポーズ検出エラー: ${snapshot.error}'));
          }
          final result = snapshot.data!;
          return Center(
            child: Column(
              children: [
                if (useMock)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('モック姿勢データで表示中', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(File(result.imagePath), fit: BoxFit.contain),
                      Positioned.fill(
                        child: Builder(builder: (context) {
                          if (useMock) {
                            // build synthetic landmarks positioned relative to image size
                            final w = result.imageSize.width;
                            final h = result.imageSize.height;
                            final landmarks = <String, Offset>{
                              'leftShoulder': Offset(w * 0.35, h * 0.25),
                              'rightShoulder': Offset(w * 0.65, h * 0.25),
                              'leftElbow': Offset(w * 0.25, h * 0.45),
                              'rightElbow': Offset(w * 0.75, h * 0.45),
                              'leftWrist': Offset(w * 0.2, h * 0.65),
                              'rightWrist': Offset(w * 0.8, h * 0.65),
                              'leftHip': Offset(w * 0.4, h * 0.55),
                              'rightHip': Offset(w * 0.6, h * 0.55),
                              'leftKnee': Offset(w * 0.45, h * 0.75),
                              'rightKnee': Offset(w * 0.55, h * 0.75),
                              'leftAnkle': Offset(w * 0.45, h * 0.95),
                              'rightAnkle': Offset(w * 0.55, h * 0.95),
                            };

                            return CustomPaint(
                              painter: MockPosePainter(imageSize: result.imageSize, landmarks: landmarks),
                            );
                          }

                          return CustomPaint(
                            painter: PosePainter(imageSize: result.imageSize, poses: result.poses),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('解析画像: ${result.imagePath}'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
