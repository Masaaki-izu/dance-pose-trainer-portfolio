import 'package:flutter/material.dart';

class MockPosePainter extends CustomPainter {
  final Size imageSize;
  final Map<String, Offset> landmarks;

  MockPosePainter({required this.imageSize, required this.landmarks});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    Offset? p(String key) {
      final o = landmarks[key];
      if (o == null) return null;
      return Offset(o.dx * scaleX, o.dy * scaleY);
    }

    void drawLineKey(String a, String b) {
      final pa = p(a);
      final pb = p(b);
      if (pa != null && pb != null) canvas.drawLine(pa, pb, paint);
    }

    // torso
    drawLineKey('leftShoulder', 'rightShoulder');
    drawLineKey('leftShoulder', 'leftHip');
    drawLineKey('rightShoulder', 'rightHip');
    drawLineKey('leftHip', 'rightHip');

    // left arm
    drawLineKey('leftShoulder', 'leftElbow');
    drawLineKey('leftElbow', 'leftWrist');

    // right arm
    drawLineKey('rightShoulder', 'rightElbow');
    drawLineKey('rightElbow', 'rightWrist');

    // legs
    drawLineKey('leftHip', 'leftKnee');
    drawLineKey('leftKnee', 'leftAnkle');
    drawLineKey('rightHip', 'rightKnee');
    drawLineKey('rightKnee', 'rightAnkle');

    // draw joints
    final jointPaint = Paint()..color = Colors.blueAccent;
    for (final o in landmarks.values) {
      final offset = Offset(o.dx * scaleX, o.dy * scaleY);
      canvas.drawCircle(offset, 6, jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MockPosePainter oldDelegate) {
    return oldDelegate.landmarks != landmarks || oldDelegate.imageSize != imageSize;
  }
}
