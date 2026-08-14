import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'recordings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dance Pose Trainer')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.videocam),
              label: const Text('カメラ録画'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen())),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('録画一覧'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordingsScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
