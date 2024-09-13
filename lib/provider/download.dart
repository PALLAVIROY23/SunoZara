import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class DownloadProvider extends ChangeNotifier {
  List<String> downloaginListx = [];
  List<String> get downloaginList => downloaginListx;
  // DownloadProvider({this.isplaying = false});

  void addDownload({
    required List<String> downloaginListn,
  }) async {
    downloaginListx = downloaginListn;

    notifyListeners();
  }

  void completeDownload({required String did}) async {
    downloaginListx.remove(did);
    // player.pause();
    notifyListeners();
  }
}
