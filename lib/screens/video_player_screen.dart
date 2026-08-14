import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/pose_service.dart';
import '../widgets/pose_painter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String path;
  const VideoPlayerScreen({Key? key, required this.path}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  PoseDetectionResult? _poseResult;
  Timer? _analysisTimer;
  bool _initialized = false;
  bool _isAnalyzing = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path));
    _controller!.addListener(_onVideoControllerUpdate);
    _controller!
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {
            _initialized = true;
            _isPlaying = _controller!.value.isPlaying;
          });
          _controller!.play();
          _startAnalysisTimer();
        })
        .catchError((e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('再生エラー: $e')));
        });
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    _controller?.removeListener(_onVideoControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  void _onVideoControllerUpdate() {
    if (!mounted || _controller == null) return;
    final controller = _controller!;
    final isPlaying = controller.value.isPlaying;
    if (isPlaying != _isPlaying) {
      _isPlaying = isPlaying;
      setState(() {});
    }

    final duration = controller.value.duration;
    if (controller.value.position >= duration) {
      _analysisTimer?.cancel();
    }

    if (isPlaying && (_analysisTimer == null || !_analysisTimer!.isActive)) {
      _startAnalysisTimer();
    }
  }

  void _startAnalysisTimer() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _scheduleAnalysis();
    });
  }

  void _scheduleAnalysis() {
    if (!mounted || _controller == null) return;
    final controller = _controller!;
    if (!controller.value.isInitialized || !controller.value.isPlaying) return;
    final position = controller.value.position;
    final duration = controller.value.duration;
    if (position >= duration) return;

    _analyzeCurrentFrame(position);
  }

  Future<void> _analyzeCurrentFrame(Duration position) async {
    if (_isAnalyzing || !mounted) return;
    _isAnalyzing = true;
    setState(() {});

    try {
      final result = await PoseService.detectPoseFromVideoFrame(
        widget.path,
        timeMs: position.inMilliseconds,
      );
      if (!mounted) return;
      setState(() {
        _poseResult = result;
      });
    } catch (e) {
      // 解析失敗時は再生を止めず、次回のタイマーに任せる
      debugPrint('Pose分析エラー: $e');
    } finally {
      _isAnalyzing = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('再生')),
      body: Center(
        child: _initialized && _controller != null
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller!),
                    if (_poseResult != null)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: PosePainter(
                            imageSize: _poseResult!.imageSize,
                            poses: _poseResult!.poses,
                          ),
                        ),
                      ),
                    if (_isAnalyzing)
                      const Positioned(
                        top: 16,
                        right: 16,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    _ControlsOverlay(controller: _controller!),
                    VideoProgressIndicator(_controller!, allowScrubbing: true),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  const _ControlsOverlay({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Center(
        child: controller.value.isPlaying
            ? const SizedBox.shrink()
            : Container(
                color: Colors.black38,
                child: const Icon(
                  Icons.play_arrow,
                  size: 64,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
