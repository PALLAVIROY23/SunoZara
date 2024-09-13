import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/audio/gradientshape.dart';
import 'package:sunozara/audio/player.dart';
import 'package:sunozara/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:audio_service/audio_service.dart';
import '../provider/miniplayer.dart';
import 'thumb.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final AudioPlayer player;
  String _selectedRadioValue = "5";
  dynamic audio;
  String current_id;
  List<String> itemIds;

  SeekBar(
      {Key? key,
      required this.duration,
      required this.position,
      required this.bufferedPosition,
      required this.audio,
      this.onChanged,
      this.onChangeEnd,
      required this.current_id,
      required this.itemIds,
      required this.player})
      : super(key: key);

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;
  ui.Image? customImage;
  String sleepText = "Timer Off";
  bool timerEnabled = false;
  Duration endsTime = Duration();
  Duration elaspedTime = Duration();
  Timer? _timer;
  final service = FlutterBackgroundService();
  TextEditingController _hour = new TextEditingController();
  TextEditingController _minutes = new TextEditingController();
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
    loadTimer();
  }

  loadTimer() {
    setState(() {
      _hour.text = "0";
      _minutes.text = "0";
    });
  }

  initCheckTimer() async {
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
            context
                .read<MiniPlayerProvider>()
                .closePlayer(nplayer: player, playing: false, isshow: true);
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
      });
    } else {
      setState(() {
        sleepText = "Timer Off";
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when disposing of the widget

    super.dispose();
  }

  Future<void> _startBackgroundService(String t) async {
    print("Starting bg service...");
    // service.invoke("stopService");
    // await service.configure(
    //   androidConfiguration: AndroidConfiguration(
    //       onStart: onStart,
    //       autoStart: true,
    //       isForegroundMode: false,
    //       initialNotificationContent: "Player will close at " + t,
    //       initialNotificationTitle: "Sleeping mode activated"),
    //   iosConfiguration: IosConfiguration(
    //     autoStart: true,
    //     onForeground: onStart,
    //     // onBackground: onIosBackground,
    //   ),
    // );
    // service.startService();
    initCheckTimerx();
  }

  Widget textFiled(
      {hinttext,
      TextInputType? ttype,
      TextEditingController? controller,
      VoidCallback? onTap,
      inputFormatters,
      validator,
      bool? readonly}) {
    return Container(
        decoration: BoxDecoration(
            // color: Colors.white, borderRadius: BorderRadius.circular(6)
            ),
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 0),
        padding: EdgeInsets.symmetric(
          horizontal: 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              hinttext,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            SizedBox(
                height: 45,
                child: TextFormField(
                  controller: controller,
                  readOnly: readonly ?? false,
                  keyboardType: ttype,
                  onTap: onTap,
                  validator: validator,
                  inputFormatters: inputFormatters,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ).copyWith(color: Colors.white),
                  decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      hintText: hinttext,
                      fillColor: Colors.black.withOpacity(0.4),
                      contentPadding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                      prefixIconColor: Color.fromARGB(255, 203, 201, 201),
                      // hintText: hinttext,
                      hintStyle: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0)
                          .copyWith(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      )),
                )),
          ],
        ));
  }

  checkInternet() {
    Fluttertoast.showToast(msg: "Kindly check internet connection");
  }

  openTimer(String v) {
    String? _selectedRadioValue;
    if (v != "") {
      _selectedRadioValue = v;
    }
    showModalBottomSheet<void>(
        context: context,
        builder: (
          BuildContext context,
        ) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    // image: DecorationImage(
                    //     image: AssetImage("assets/player_bg.png"), fit: BoxFit.cover),
                    color: HexColor("212226"),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                height: 350,
                // color: Colors.amber,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'Set Sleep Timer',
                        style: GoogleFonts.roboto(
                            fontSize: 18, color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'Choose when you want to stop your audio automatically.',
                        style: GoogleFonts.roboto(
                            fontSize: 14, color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                    Container(
                      height: 40,
                      child: RadioListTile<String>(
                        dense: true,
                        fillColor: MaterialStatePropertyAll(Colors.redAccent),
                        title: Text(
                          '5 minutes',
                          style: GoogleFonts.roboto(
                              color: Colors.white, fontSize: 16),
                        ),
                        value: "5",
                        groupValue: _selectedRadioValue,
                        onChanged: (String? value) {
                          //print(value);
                          setState(() {
                            _selectedRadioValue = value!;
                            _minutes.text = value;
                          });
                          Navigator.pop(context);
                          setTimer();
                        },
                      ),
                    ),
                    Container(
                        height: 40,
                        child: RadioListTile<String>(
                          dense: true,
                          fillColor: MaterialStatePropertyAll(Colors.redAccent),
                          title: Text(
                            '10 minutes',
                            style: GoogleFonts.roboto(
                                color: Colors.white, fontSize: 16),
                          ),
                          value: "10",
                          groupValue: _selectedRadioValue,
                          onChanged: (String? value) {
                            //print(value);
                            setState(() {
                              _selectedRadioValue = value!;
                              _minutes.text = value;
                            });
                            Navigator.pop(context);
                            setTimer();
                          },
                        )),
                    Container(
                        height: 40,
                        child: RadioListTile<String>(
                          dense: true,
                          fillColor: MaterialStatePropertyAll(Colors.redAccent),
                          title: Text(
                            '30 minutes',
                            style: GoogleFonts.roboto(
                                color: Colors.white, fontSize: 16),
                          ),
                          value: "30",
                          groupValue: _selectedRadioValue,
                          onChanged: (String? value) {
                            //print(value);
                            setState(() {
                              _selectedRadioValue = value!;
                              _minutes.text = value;
                            });
                            Navigator.pop(context);
                            setTimer();
                          },
                        )),
                    Container(
                        height: 40,
                        child: RadioListTile<String>(
                          dense: true,
                          title: Text(
                            '1 hour',
                            style: GoogleFonts.roboto(
                                color: Colors.white, fontSize: 16),
                          ),
                          fillColor: MaterialStatePropertyAll(Colors.redAccent),
                          value: "60",
                          groupValue: _selectedRadioValue,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedRadioValue = value!;
                              _minutes.text = value;
                            });
                            Navigator.pop(context);
                            setTimer();
                            //print(value);
                          },
                        )),
                    Container(
                        height: 40,
                        child: RadioListTile<String>(
                          dense: true,
                          title: Text(
                            'Custom',
                            style: GoogleFonts.roboto(
                                color: Colors.white, fontSize: 16),
                          ),
                          fillColor: MaterialStatePropertyAll(Colors.redAccent),
                          value: "80",
                          groupValue: _selectedRadioValue,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedRadioValue = value!;
                              _minutes.text = "30";
                            });
                            Navigator.pop(context);
                            openTimerT();
                          },
                        )),
                  ],
                ),
              );
            },
          );
        });
  }

  bool isStringDouble(String value) {
    if (value.isEmpty) {
      return false;
    }
    final doubleValue = int.tryParse(value);
    return doubleValue == null;
  }

  openTimerT() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Set sleep timer',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: Container(
            height: 75,
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: textFiled(
                      hinttext: "Hour",
                      ttype: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                      controller: _hour),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: textFiled(
                      hinttext: "Mins.",
                      ttype: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                      controller: _minutes),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                'Set Now',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onPressed: () {
                if (_hour.text.trim().toString() != "" &&
                    _minutes.text.trim().toString() != "") {
                  if (_hour.text.trim().toString() != "0" ||
                      _minutes.text.trim().toString() != "0") {
                    if (isStringDouble(_hour.text.toString()) ||
                        isStringDouble(_minutes.text.toString())) {
                      Fluttertoast.showToast(
                          msg: "Decimal Values not allowed.");
                    } else {
                      Navigator.of(context).pop();
                      setTimer();
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: "Timer can not set for 0 minutes.");
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "Kindly provide value to set timer.");
                }
              },
            ),
          ],
        );
      },
    );
  }

  openCloser() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Sleep timer',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: Text(
            "Do you want to stop sleep timer?",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                'Stop Now',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                stopTimer();
              },
            ),
          ],
        );
      },
    );
  }

  stopTimer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("timerEnabled", false);
    service.invoke("stopService");
    _timer!.cancel();
    initCheckTimer();
    Fluttertoast.showToast(msg: "Sleep timer has been disabled successfully.");
  }

  setTimer() async {
    //print("Hello");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("timerEnabled", true);
    int totalsec = int.parse(_hour.text.toString()) * 3600 +
        int.parse(_minutes.text.toString()) * 60;
    DateTime ed = DateTime.now().add(Duration(seconds: totalsec));
    prefs.setInt("endsTime", ed.microsecondsSinceEpoch);
    service.isRunning().then((value) => {service.invoke("stopService")});

    // service.startService();
    service.invoke("setAsBackground");
    _startBackgroundService(ed.toIso8601String());
    initCheckTimer();
    setState(() {
      _minutes.text = "0";
    });
    Fluttertoast.showToast(msg: "Sleep timer has been set successfully.");
    // service.stopSelf();
  }

  Future<ui.Image> load(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  mfD(data) async {
    setState(() {
      widget.audio["fav"] = widget.audio["fav"] == "1" ? "0" : "1";
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList =
        jsonDecode(prefs.getString("favorite_list").toString());

    if (widget.audio["fav"] == '1') {
      if (sliderList != 'null') {
        dynamic list = [];
        list.add(widget.audio);
        prefs.setString("favorite_list", jsonEncode(list));
      } else {
        sliderList.add(widget.audio);
        prefs.setString("favorite_list", jsonEncode(sliderList));
      }
    } else {
      dynamic list = [];

      for (int i = 0; i < sliderList.length; i++) {
        if (sliderList[i]["id"].toString() != widget.audio["id"].toString()) {
          list.add(sliderList[i]);
        }
      }
      prefs.setString("favorite_list", jsonEncode(list));
    }

    Fluttertoast.showToast(msg: "Audio favorite list status changed.");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 15.0,
      inactiveTrackColor: Colors.grey,
      // thumbShape: SliderThumbImage(customImage!),
      trackShape: GradientRectSliderTrackShape(
          gradient: gradient, darkenInactive: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.grey,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: widget.itemIds.contains(widget.current_id)
                ? min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
                    widget.duration.inMilliseconds.toDouble())
                : 0,
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
        Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.itemIds.contains(widget.current_id)
                    ? Container(
                        width: 40,
                        child: Text(
                            RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                                    .firstMatch("$_current")
                                    ?.group(1) ??
                                '$_current',
                            style: GoogleFonts.poppins(
                                color: Colors.red, fontSize: 12)),
                      )
                    : SizedBox(
                        width: 40,
                      ),
                StreamBuilder<double>(
                  stream: widget.player.speedStream,
                  builder: (context, snapshot) => snapshot.data != null
                      ? IconButton(
                          icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                              style: GoogleFonts.poppins(color: Colors.white)),
                          onPressed: () {
                            showSliderDialog(
                              context: context,
                              title: "Adjust speed",
                              divisions: 10,
                              min: 0.5,
                              max: 1.5,
                              value: widget.player.speed,
                              stream: widget.player.speedStream,
                              onChanged: widget.player.setSpeed,
                            );
                          },
                        )
                      : SizedBox(),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showSliderDialog(
                      context: context,
                      title: "Adjust volume",
                      divisions: 10,
                      min: 0.0,
                      max: 1.0,
                      value: widget.player.volume,
                      stream: widget.player.volumeStream,
                      onChanged: widget.player.setVolume,
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    widget.audio["fav"].toString() == "0"
                        ? MdiIcons.heartOutline
                        : MdiIcons.heart,
                    color: widget.audio["fav"].toString() == "0"
                        ? Colors.white
                        : Colors.redAccent,
                  ),
                  onPressed: () {
                    ApiService()
                        .markFavAudio(widget.audio["id"].toString())
                        .then((value) => {mfD(value)})
                        .onError((error, stackTrace) => {checkInternet()});
                  },
                ),
                widget.itemIds.contains(widget.current_id)
                    ? Container(
                        width: 40.h,
                        child: Text(
                            RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                                    .firstMatch("$_duration")
                                    ?.group(1) ??
                                '$_duration',
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 12.sp)))
                    : SizedBox(
                        width: 40.h,
                      )
              ],
            )),
        StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              return player.playing
                  ? Container(
                      width: 130.w,
                      decoration: BoxDecoration(
                          color: ui.Color.fromARGB(255, 61, 49, 49),
                          borderRadius: BorderRadius.circular(20)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      child: InkWell(
                        onTap: () async {
                          //print("Hello");
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          bool? fn = prefs.getBool("timerEnabled");
                          if (fn == null) {
                            openTimer(_minutes.text);
                          }
                          if (fn!) {
                            openCloser();
                          } else {
                            openTimer(_minutes.text);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.alarm,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              sleepText.toString(),
                              style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    )
                  : SizedBox();
            })
      ],
    ));
  }

  Duration get _remaining => widget.duration - widget.position;
  Duration get _current => widget.position;
  Duration get _duration => widget.duration;

  closePLayer(player) {
    Provider.of<MiniPlayerProvider>(context, listen: false)
        .closePlayer(nplayer: player, playing: false, isshow: true);
  }

  initCheckTimerx() async {
    Timer? _timer;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool timerEnabled = prefs.getBool("timerEnabled")!;
    print("running1");
    if (timerEnabled) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        DateTime ed = DateTime.now();
        int? endsTime = prefs.getInt("endsTime");
        //print("Running");
        print("running");
        bool timerEnableded = prefs.getBool("timerEnabled")!;
        if (timerEnableded) {
          if (endsTime != null) {
            if (ed.microsecondsSinceEpoch >= endsTime) {
              // ignore: deprecated_member_use
              await AudioService.pause();
              // closePLayer(context);
              // closePLayer(player);
              player.pause();
              print("runningx");
              _timer?.cancel();
              prefs.setBool("timerEnabled", false);
            } else {
              //print("onRunning");
            }
          }
        } else {
          _timer?.cancel();
        }
      });
    }
  }
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
}

T? ambiguate<T>(T? value) => value;
