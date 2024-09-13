import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/audio/gradientshape.dart';
import 'package:sunozara/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:audio_service/audio_service.dart';

import 'thumb.dart';

class SeekBarMini extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final AudioPlayer player;

  SeekBarMini(
      {Key? key,
      required this.duration,
      required this.position,
      required this.bufferedPosition,
      this.onChanged,
      this.onChangeEnd,
      required this.player})
      : super(key: key);

  @override
  SeekBarMiniState createState() => SeekBarMiniState();
}

class SeekBarMiniState extends State<SeekBarMini> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;
  ui.Image? customImage;
  String sleepText = "Timer Off";
  bool timerEnabled = false;
  Duration endsTime = Duration();
  Duration elaspedTime = Duration();
  Timer? _timer;
  final service = FlutterBackgroundService();
  LinearGradient gradient =
      LinearGradient(colors: <Color>[Color(0xFFE71F2E), Color(0xFF374AF9)]);
  @override
  void initState() {
    load('assets/thumb.png').then((image) {
      setState(() {
        customImage = image;
      });
    });
    super.initState();
    initCheckTimer();
    loadListener();
  }

  loadListener() {
    player.playbackEventStream.listen((event) {
      if (player.sequenceState != null) {}
    }, onError: (Object e, StackTrace stackTrace) {
      //print('A stream error occurred: $e');
    });
  }

  initCheckTimer() async {
    print("mini player");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getBool("timerEnabled") != null) {
        timerEnabled = prefs.getBool("timerEnabled")!;
      } else {
        timerEnabled = false;
      }
    });

    if (timerEnabled) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        DateTime ed = DateTime.now();
        int? endsTime = prefs.getInt("endsTime");
        if (endsTime != null) {
          if (ed.microsecondsSinceEpoch >= endsTime) {
            player.pause();
            _timer!.cancel();
            prefs.setBool("timerEnabled", false);
          } else {
            DateTime dt = DateTime.fromMicrosecondsSinceEpoch(endsTime);
            Duration dx = dt.difference(ed);

            setState(() {
              sleepText =
                  (dx.inHours < 10 ? "0" + dx.inHours.toString() : dx.inHours)
                          .toString() +
                      ":" +
                      ((dx.inMinutes % 60) < 10
                              ? "0" + (dx.inMinutes % 60).toString()
                              : (dx.inMinutes % 60))
                          .toString() +
                      ":" +
                      ((dx.inSeconds % 60) < 10
                              ? "0" + (dx.inSeconds % 60).toString()
                              : (dx.inSeconds % 60))
                          .toString();
            });
          }
        }

        //print(sleepText);
      });
    } else {
      if (_timer != null) {
        _timer!.cancel();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when disposing of the widget

    super.dispose();
  }

  Future<void> _startBackgroundService(String t) async {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: true,
          isForegroundMode: false,
          initialNotificationContent: "Player will close at " + t,
          initialNotificationTitle: "Sleeping mode activated"),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        // onBackground: onIosBackground,
      ),
    );
    service.startService();
  }

  setTimer() async {
    //print("Hello");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("timerEnabled", true);
    int totalsec = 50;
    DateTime ed = DateTime.now().add(Duration(seconds: totalsec));
    prefs.setInt("endsTime", ed.microsecondsSinceEpoch);
    service.isRunning().then((value) => {service.invoke("stopService")});

    // service.startService();
    service.invoke("setAsBackground");
    _startBackgroundService(ed.toIso8601String());
    initCheckTimer();
    // service.stopSelf();
  }

  Future<ui.Image> load(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  mfD(data) {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      inactiveTrackColor: Colors.grey,
      thumbColor: Colors.transparent,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
      trackShape: GradientRectSliderTrackShape(
          gradient: gradient, darkenInactive: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        SizedBox(
          height: 15,
          child: SliderTheme(
            data: _sliderThemeData.copyWith(
              inactiveTrackColor: Colors.grey,
              trackHeight: 3,
            ),
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: min(
                  _dragValue ?? widget.position.inMilliseconds.toDouble(),
                  widget.duration.inMilliseconds.toDouble()),
              onChanged: (value) {
                setState(() {
                  _dragValue = value;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(Duration(milliseconds: value.round()));
                }
              },
              onChangeEnd: (value) {
                if (widget.onChangeEnd != null) {
                  widget.onChangeEnd!(Duration(milliseconds: value.round()));
                }
                _dragValue = null;
              },
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.only(left: 20, right: 10),
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  child: Text(
                      RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                              .firstMatch("$_current")
                              ?.group(1) ??
                          '$_current',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 12)),
                ),
                Container(
                    width: 40,
                    child: Text(
                        RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                                .firstMatch("$_duration")
                                ?.group(1) ??
                            '$_duration',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 12)))
              ],
            )),
      ],
    ));
  }

  Duration get _remaining => widget.duration - widget.position;
  Duration get _current => widget.position;
  Duration get _duration => widget.duration;
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  // TODO: Replace these two by ValueStream.
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  initCheckTimerx(service);
}

initCheckTimerx(ServiceInstance service) async {
  Timer? _timer;
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  bool timerEnabled = prefs.getBool("timerEnabled")!;

  //print(prefs.getInt("endsTime")!);
  if (timerEnabled) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      DateTime ed = DateTime.now();
      int? endsTime = prefs.getInt("endsTime");
      //print("Running");
      if (endsTime != null) {
        if (ed.microsecondsSinceEpoch >= endsTime) {
          // ignore: deprecated_member_use
          await AudioService.stop();
          // player.stop();
          _timer?.cancel();
          prefs.setBool("timerEnabled", false);
          service.invoke("stopService");
          service.stopSelf();
        } else {
          //print("onRunning");
        }
      }
    });
  }
}

T? ambiguate<T>(T? value) => value;
