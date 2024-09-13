import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayerProvider extends ChangeNotifier {
  AudioPlayer player = AudioPlayer();
  bool _isplaying = false;
  bool _isshow = false;
  List<ClippingAudioSource> episodesx = [];
  List<ClippingAudioSource> get episodes => episodesx;

  AudioPlayer get playerd => player;
  bool get isplaying => _isplaying;
  bool get isshow => _isshow;
  // MiniPlayerProvider({this.isplaying = false});

  void changePlayer(
      {required AudioPlayer nplayer,
      required bool playing,
      required List<ClippingAudioSource> nepisodes,
      required bool isshow}) async {
    player = nplayer;
    _isplaying = playing;
    episodesx = nepisodes;
    _isshow = isshow;
    notifyListeners();
  }

  void closePlayer(
      {required AudioPlayer nplayer,
      required bool playing,
      required bool isshow}) async {
    player = nplayer;
    _isplaying = playing;
    _isshow = isshow;
    // player.pause();
    notifyListeners();
  }
}
