import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const _channel = MethodChannel('uniroid/updater');

class Updater {
  static const feedUrl = 'https://raw.githubusercontent.com/MenaAmmarPro/uniroid/main/feed.json';

  static Future<String?> latestVersion() async {
    final res = await http.get(Uri.parse(feedUrl));
    if (res.statusCode != 200) return null;
    final m = RegExp(r'"latestVersion"\s*:\s*"([^"]+)"').firstMatch(res.body);
    return m?.group(1);
  }

  static Future<File> downloadApk(String url) async {
    final res = await http.get(Uri.parse(url));
    final file = File('${Directory.systemTemp.path}/uniroid-update.apk');
    await file.writeAsBytes(res.bodyBytes);
    return file;
  }

  static Future<void> install(File file) async {
    await _channel.invokeMethod('install', {'path': file.path});
  }
}
