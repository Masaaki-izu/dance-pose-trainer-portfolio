import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Size imageSize;
  final List<Pose> poses;

  PosePainter({required this.imageSize, required this.poses});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (final pose in poses) {
      final landmarks = pose.landmarks;
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, scaleX, scaleY);
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, scaleX, scaleY);
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, scaleX, scaleY);
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, scaleX, scaleY);
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, scaleX, scaleY);
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, scaleX, scaleY);
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, scaleX, scaleY);
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, scaleX, scaleY);
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, scaleX, scaleY);
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, scaleX, scaleY);
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, scaleX, scaleY);
      _drawLine(canvas, paint, landmarks, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, scaleX, scaleY);

      for (final landmark in landmarks.values) {
        final offset = Offset(landmark.x * scaleX, landmark.y * scaleY);
        canvas.drawCircle(offset, 6, paint..style = PaintingStyle.fill);
      }
    }
  }

  void _drawLine(Canvas canvas, Paint paint, Map<PoseLandmarkType, PoseLandmark> landmarks, PoseLandmarkType a, PoseLandmarkType b, double scaleX, double scaleY) {
    if (landmarks.containsKey(a) && landmarks.containsKey(b)) {
      final start = landmarks[a]!;
      final end = landmarks[b]!;
      final p1 = Offset(start.x * scaleX, start.y * scaleY);
      final p2 = Offset(end.x * scaleX, end.y * scaleY);
      canvas.drawLine(p1, p2, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses || oldDelegate.imageSize != imageSize;
  }
}
