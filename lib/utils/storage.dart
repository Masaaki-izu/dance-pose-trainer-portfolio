import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Storage {
  static const _folderName = 'recordings';

  static Future<Directory> _getRecordingsDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory('${dir.path}/$_folderName');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    return recordingsDir;
  }

  static Future<String> saveRecordingFromPath(String sourcePath) async {
    final recordingsDir = await _getRecordingsDir();
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final destPath = '${recordingsDir.path}/recording_$timestamp.mp4';
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw FileSystemException('録画ファイルが見つかりません', sourcePath);
    }

    await sourceFile.copy(destPath);
    return destPath;
  }

  static Future<List<FileSystemEntity>> listRecordings() async {
    final recordingsDir = await _getRecordingsDir();
    final list = recordingsDir.listSync().where((e) => e.path.endsWith('.mp4')).toList();
    list.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return list;
  }

  static Future<void> deleteRecording(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
