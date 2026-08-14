import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/storage.dart';
import 'video_player_screen.dart';

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({Key? key}) : super(key: key);

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  List<FileSystemEntity> _recordings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await Storage.listRecordings();
    setState(() {
      _recordings = list;
      _loading = false;
    });
  }

  Future<void> _delete(String path) async {
    await Storage.deleteRecording(path);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('録画一覧')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _recordings.isEmpty
              ? const Center(child: Text('録画がありません'))
              : ListView.builder(
                  itemCount: _recordings.length,
                  itemBuilder: (context, index) {
                    final file = _recordings[index];
                    final name = file.path.split('/').last;
                    final modified = file.statSync().modified;
                    return ListTile(
                      title: Text(name),
                      subtitle: Text('更新: ${modified.toLocal()}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _delete(file.path),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(path: file.path),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
