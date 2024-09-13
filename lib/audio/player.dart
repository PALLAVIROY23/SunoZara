import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/audio/edit_review.dart';
import 'package:sunozara/constants.dart';
import 'package:gradient_slider/gradient_slider.dart';
import 'package:sunozara/dashboard_tab.dart';
import 'package:sunozara/provider/download.dart';
import 'package:sunozara/provider/miniplayer.dart';
import 'package:sunozara/subscription/info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../api/api_constant.dart';
import '../constants.dart';
import '../dashboard.dart';
import '../placeholders.dart';
import '../search.dart';
import '../widget/bottom.dart';
import 'category_item.dart';
import 'favorite.dart';
import 'my_downloads.dart';
import 'player_common.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'review.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:animated_icon/animated_icon.dart';

class AudioPlayerScreen extends StatefulWidget {
  dynamic audio;
  int index;
  String skey;
  String type;
  AudioPlayerScreen(this.audio, this.type,
      {this.index = 0, this.skey = "", super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static int _nextMediaId = 0;
  late TabController tabController;
  int selectedIndex = 0;
  bool deleting = false;
  FToast? fToast;
  bool loaded = false;
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  int _addedCount = 0;
  int initial = 1;
  bool isPayment = false;
  bool downloading = false;
  dynamic myrate;
  dynamic ratingList = [];
  dynamic yourRating;
  String current_id = "";
  String? old_current_id;
  List<String> itemIds = [];
  List<String> itedmDownloads = [];
  String fi_title = "";
  String fi_image = "";
  String current_audio_id = "";
  String current_download = "";
  List<String> downloadingList = [];
  int downloadcount = 0;

  List<ClippingAudioSource> episodes = [];
  List<ClippingAudioSource> eepisodes = [];
  bool is_downloaded = false;
  bool subscribed = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Timer? _timer;
  @override
  void initState() {
    super.initState();

    tabController = TabController(
      initialIndex: selectedIndex,
      length: 3,
      vsync: this,
    );
    tabController.addListener(_handleTabSelection);

    loadData(0);
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));

    fToast = FToast();
    fToast?.init(context);
    fToast?.removeCustomToast();
  }

  _handleTabSelection() {
    setState(() {
      selectedIndex = tabController.index;
    });
  }

  void _onRefresh() async {
    // monitor network fetch
    ////print("Loading");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? subs = prefs.getBool("subscription");
    loadData(0);
    setState(() {
      subscribed = subs!;
    });
    await Future.delayed(Duration(milliseconds: 2000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    ////print("Loading");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? subs = prefs.getBool("subscription");
    loadData(0);
    setState(() {
      subscribed = subs!;
    });
    if (mounted) {}
    await Future.delayed(Duration(milliseconds: 2000));
    _refreshController.loadComplete();
  }

  purchase() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: HexColor("212226"),
          title: Text(
            'Content is locked',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: Text(
            "Kindly buy subscription to listen locked content. Player will be stopped while making payment.",
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
                'Buy Now',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onPressed: () {
                // Navigator.of(context).pop();
                player.stop();
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight,
                        alignment: Alignment.bottomCenter,
                        child: SubscriptionInfoScreen(
                          isPurchased: (bool l) {
                            if (l) {
                              setState(() {
                                subscribed = true;
                              });
                              loadData(selectedIndex);
                            }
                          },
                        )));
              },
            ),
          ],
        );
      },
    );
  }

  checkStatus() async {
    Future.delayed(Duration(seconds: 1), () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      print(downloadingList);
      print("downloadingList");
      String uid = prefs.getString("user_id").toString();
      if (downloadingList.length > 0) {
        for (int i = 0; i < downloadingList.length; i++) {
          bool? x = prefs.getBool("download_id_${downloadingList[i]}_${uid}");
          if (x != null) {
            context
                .read<DownloadProvider>()
                .completeDownload(did: downloadingList[i].toString());
            setState(() {
              downloadingList.remove(downloadingList[i].toString());
            });
            prefs.setString("downloadingList", jsonEncode(downloadingList));
            loadData(0);
          }
        }
        if (downloadingList.length > 0) {
          checkStatus();
        }
      }
    });
  }

  episodesData(data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("audio_data_${widget.audio['id']}", jsonEncode(data));
    String uid = prefs.getString("user_id").toString();
    prefs.setString(
        "audio_info_${widget.audio['id']}", jsonEncode(widget.audio));
    List<ClippingAudioSource> nepisodes = [];
    List<ClippingAudioSource> neepisodes = [];

    checkStatus();
    ////print(data["selfRating"]);
    ////print("sanjay");
    setState(() {
      yourRating = data["selfRating"];
      ratingList = data["ratings"];
      myrate = data["myrate"];
    });

    bool dl = false;

    String? current_idx = prefs.getString("current_id");

    for (int i = 0; i < data["data"].length; i++) {
      if (i == 0) {
        // if (!player.playing) {
        fi_title = data["data"][i]["title"].toString();
        fi_image = ApiConstants.storagePATH +
            "/episodes/" +
            data["data"][i]["image"].toString();
        // }
      }
      setState(() {
        itemIds.add(data["data"][i]["id"].toString());
      });
      if (data["data"][i]["type"] == "free" || subscribed) {
        bool? x = prefs.getBool("download_id_${data["data"][i]["id"]}_${uid}");

        // print("download_id_${data["data"][i]["id"]}_${uid}");
        // print("dddxxx");
        if (x == true) {
          setState(() {
            is_downloaded = true;
            itedmDownloads.add(data["data"][i]["id"].toString());
          });
        }
        // x = false;
        String? path =
            prefs.getString("file_id_${data["data"][i]["id"]}_${uid}");

        neepisodes.add(ClippingAudioSource(
          // start: const Duration(seconds: 60),
          // end: const Duration(seconds: 90),
          duration: Duration(
              seconds: int.parse(
                  data["data"][i]["duration"].toString() != 'null'
                      ? data["data"][i]["duration"].toString()
                      : "0")),
          child: x == true
              ? AudioSource.uri(Uri.parse(path!))
              : AudioSource.uri(Uri.parse(ApiConstants.storagePATH +
                  "/episodes/" +
                  data["data"][i]["audio_file"].toString())),
          tag: MediaItem(
            extras: {
              "type": data["data"][i]["type"].toString(),
              "audio": widget.audio,
              "audio_list_id": widget.audio["id"],
            },
            id: data["data"][i]["id"].toString(),
            album: data["data"][i]["audio"]["name"].toString(),
            title: data["data"][i]["title"].toString(),
            artUri: Uri.parse(ApiConstants.storagePATH +
                "/episodes/" +
                data["data"][i]["image"].toString()),
          ),
        ));
      }
      nepisodes.add(ClippingAudioSource(
        // start: const Duration(seconds: 60),
        // end: const Duration(seconds: 90),
        duration: Duration(
            seconds: int.parse(data["data"][i]["duration"].toString() != 'null'
                ? data["data"][i]["duration"].toString()
                : "0")),
        child: AudioSource.uri(Uri.parse(ApiConstants.storagePATH +
            "/episodes/" +
            data["data"][i]["audio_file"].toString())),
        tag: MediaItem(
          extras: {
            "type": data["data"][i]["type"].toString(),
            "audio": widget.audio,
            "audio_list_id": widget.audio["id"],
          },
          id: data["data"][i]["id"].toString(),
          album: data["data"][i]["audio"]["name"].toString(),
          title: data["data"][i]["title"].toString(),
          artUri: Uri.parse(ApiConstants.storagePATH +
              "/episodes/" +
              data["data"][i]["image"].toString()),
        ),
      ));
      // }
    }

    if (current_idx == null) {
      setState(() {
        current_id = itemIds[0].toString();
      });
    } else {
      if (itemIds.contains(current_idx)) {
        setState(() {
          current_id = current_idx;
        });
      } else {
        setState(() {
          current_id = itemIds[0].toString();
          old_current_id = current_idx;
        });
      }
    }

    ////print(current_id);
    ////print("eeeeeeeeeeee");
    ////print(fi_title);
    ////print(fi_image);

    prefs.setString("current_id", current_id);

    setState(() {
      episodes = neepisodes;
      eepisodes = nepisodes;
    });

    setState(() {
      _playlist = ConcatenatingAudioSource(children: neepisodes);
    });

    _init();
  }

  markDownload(String eid) async {
    ApiService()
        .setAudioDownload(widget.audio["id"].toString(), eid)
        .then((value) {})
        .onError((error, stackTrace) {});
  }

  Future<void> downloadFile(String url, String filename, String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("user_id").toString();
    // Fluttertoast.showToast(msg: "Download started");
    setState(() {
      current_download = id.toString();
      downloadingList.add(id.toString());
    });
    List<String> xlx = context.read<DownloadProvider>().downloaginList;
    xlx.add(id.toString());
    context.read<DownloadProvider>().addDownload(downloaginListn: xlx);

    prefs.setString("downloadingList", jsonEncode(downloadingList));
    print(downloadingList);
    print("sksch");
    Dio dio = Dio();

    String? downloadList_str = prefs.getString("downloadList_${uid}");
    dynamic downloadList = [];
    if (downloadList_str != null) {
      downloadList = jsonDecode(downloadList_str);
      if (!downloadList.contains(widget.audio["id"])) {
        downloadList.add(widget.audio["id"]);
      }
    } else {
      downloadList.add(widget.audio["id"]);
    }

    prefs.setString("downloadList_${uid}", jsonEncode(downloadList));
    //print("dlist");
    //print(downloadList_str);

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String savePath = "${appDocDir.path}/${filename}";
    markDownload(id);

    // FlutterDownloader.enqueue(
    //         url: url,
    //         savedDir: appDocDir.path,
    //         fileName: filename,
    //         openFileFromNotification: false,
    //         showNotification: false)
    //     .then((value) {
    //   print(value);
    //   prefs.setBool("download_id_${id}_${uid}", true);
    //   prefs.setString("file_id_${id}_${uid}", savePath);
    //   setState(() {
    //     downloadingList.remove(id.toString());
    //   });
    //   prefs.setString("downloadingList", jsonEncode(downloadingList));
    //   String? edx = prefs.getString("audio_data_${widget.audio['id']}");
    //   if (edx != null) {
    //     episodesData(jsonDecode(edx));
    //   }
    // }).onError((error, stackTrace) {
    //   print(error);
    //   erx(id, url, filename);
    // });
    try {
      Response response = await dio.download(url, savePath,
          onReceiveProgress: (received, total) {
        if (received == total) {
          print(received);
          prefs.setBool("download_id_${id}_${uid}", true);
          prefs.setString("file_id_${id}_${uid}", savePath);
          setState(() {
            downloadingList.remove(id.toString());
          });
          context.read<DownloadProvider>().completeDownload(did: id.toString());
          prefs.setString("downloadingList", jsonEncode(downloadingList));
          String? edx = prefs.getString("audio_data_${widget.audio['id']}");
          if (edx != null) {
            episodesData(jsonDecode(edx));
          }
        }
      });
      // markDownload(id);
      if (response.statusCode == 200) {
        ////print('File downloaded successfully!');
        prefs.setBool("download_id_${id}_${uid}", true);
        prefs.setString("file_id_${id}_${uid}", savePath);

        // if (downloadcount == episodes.length) {
        setState(() {
          downloadcount++;
          is_downloaded = true;
          downloading = false;
          current_download = "";
          itedmDownloads.add(id.toString());
        });
        // loadData(0);
        setState(() {
          downloadingList.remove(id.toString());
        });
        context.read<DownloadProvider>().completeDownload(did: id.toString());
        prefs.setString("downloadingList", jsonEncode(downloadingList));
        String? edx = prefs.getString("audio_data_${widget.audio['id']}");
        if (edx != null) {
          episodesData(jsonDecode(edx));
        }

        print(downloadingList);
        print("sanjay");

        Fluttertoast.showToast(msg: "Download completed");
      } else {
        erx(id, url, filename);
      }
    } catch (e) {
      // Handle errors
      // erx(id, url, filename);
    }
  }

  erx(String id, String url, String filename) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    context.read<DownloadProvider>().completeDownload(did: id.toString());
    setState(() {
      downloadingList.remove(id.toString());
    });

    prefs.setString("downloadingList", jsonEncode(downloadingList));
    Fluttertoast.showToast(msg: "Kindly check internet connection to download");
    Future.delayed(Duration(seconds: 3), () {
      downloadFile(url, filename, id.toString());
    });
  }

  download() async {
    setState(() {
      downloading = true;
      downloadcount = 0;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < episodes.length; i++) {
      // ////print(eepisodes[i].tag.id + ".mp3");
      downloadFile(episodes[i].child.uri.toString(),
          eepisodes[i].tag.id + ".mp3", eepisodes[i].tag.id.toString());
    }
  }

  loadData(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? subs = prefs.getBool("subscription");
    String? downloadingListx = prefs.getString("downloadingList");
    if (downloadingListx != null) {
      setState(() {
        downloadingList = List<String>.from(jsonDecode(downloadingListx));
      });
      print(downloadingList);
      print("dddlll");
    }
    setState(() {
      subscribed = subs!;
    });
    if (index != 1) {
      setState(() {
        selectedIndex = widget.index;
      });
    }
    loadLocal();
    ApiService()
        .getAudioEpisodes(widget.audio["id"].toString())
        .then((value) => {episodesData(value)})
        .onError((error, stackTrace) => lep());

    setState(() {
      current_audio_id = (prefs.getString("playing_audio_id") != null
          ? prefs.getString("playing_audio_id")
          : "")!;
    });

    dynamic sliderList =
        jsonDecode(prefs.getString("favorite_list").toString());

    if (sliderList != null) {
      bool found = false;
      for (int i = 0; i < sliderList.length; i++) {
        if (sliderList[i]["id"].toString() == widget.audio["id"].toString()) {
          found = true;
          break;
        }
      }

      if (found) {
        setState(() {
          widget.audio["fav"] = '1';
        });
      } else {
        setState(() {
          widget.audio["fav"] = '0';
        });
      }
    }
  }

  lep() async {
    await Future.delayed(Duration(seconds: 3));
    // loadData(0);
    Fluttertoast.showToast(msg: "Kindly check internet and refresh");
  }

  loadLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? subs = prefs.getBool("subscription");
    setState(() {
      subscribed = subs!;
    });
    dynamic data = jsonDecode(
        prefs.getString("audio_data_${widget.audio['id']}").toString());

    if (data != null) {
      episodesData(data);

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _init() async {
    ////print(itemIds);
    ////print(current_id);
    final session = await AudioSession.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    if (!player.playing) {
      setState(() {
        current_audio_id = widget.audio["id"].toString();
      });

      player.playbackEventStream.listen((event) {
        if (player.sequenceState != null) {
          final mt = player.sequenceState!.currentSource!.tag as MediaItem;
          //print(player.position.inSeconds);
          if (current_id != mt.id.toString() && player.position.inSeconds > 0) {
            if (player.playing) {
              if (mounted) {
                setData(mt.id.toString());
              }
            }
          }
        }
      }, onError: (Object e, StackTrace stackTrace) {
        ////print('A stream error occurred: $e');
      });
      // print(old_current_id);
      // print("old_current_id");
      if (old_current_id == null) {
        if (itemIds.contains(current_id)) {
          int idx = -1;
          for (int i = 0; i < episodes.length; i++) {
            if (episodes[i].tag.id.toString() == current_id) {
              idx = i;
            }
          }
          // //print("not playong...1");
          // ////print(episodes[idx].tag.id.toString());
          if (idx >= 0 && idx < episodes.length) {
            // await player.setAudioSource(_playlist);
            if (idx != 0) {
              // loadplayseek(idx, current_id);
              // player.seek(Duration.zero, index: idx);
              // context.read<MiniPlayerProvider>().changePlayer(
              //     nplayer: player,
              //     playing: false,
              //     nepisodes: episodes,
              //     isshow: true);

              ////print("not playong...");
              ////print(episodes[idx].tag);
              // if (player.audioSource == null) {
              //   await player.setAudioSource(_playlist);
              // }
              setState(() {
                fi_image = episodes[idx].tag.artUri.toString();
                fi_title = episodes[idx].tag.title.toString();
              });
            } else {
              setState(() {
                fi_image = episodes[idx].tag.artUri.toString();
                fi_title = episodes[idx].tag.title.toString();
              });
              try {
                // if (player.currentIndex == null) {
                await player.setAudioSource(_playlist);
                // context.read<MiniPlayerProvider>().changePlayer(
                //     nplayer: player, playing: false, nepisodes: episodes);
                // }
              } catch (e, stackTrace) {
                // Catch load errors: 404, invalid url ...
                ////print("Error loading playlist: $e");
                ////print(stackTrace);
              }
            }
            // player.play();
            // player.load();
          }
        } else {
          // fi_title = data["data"][i]["title"].toString();
          ///
          ////print("Audio has to be loaded");
          setState(() {
            fi_image = episodes[0].tag.artUri.toString();
            fi_title = episodes[0].tag.title.toString();
          });
          try {
            await player.setAudioSource(_playlist).then((value) {
              player.play();
              player.pause();
              context.read<MiniPlayerProvider>().changePlayer(
                  nplayer: player,
                  playing: false,
                  nepisodes: episodes,
                  isshow: false);
            });
          } catch (e, stackTrace) {
            // Catch load errors: 404, invalid url ...
            ////print("Error loading playlist: $e");
            ////print(stackTrace);
          }
        }
      } else {
        setData(old_current_id);
      }
    } else {
      player.playbackEventStream.listen((event) {
        final mt = player.sequenceState!.currentSource!.tag as MediaItem;
        if (current_id != mt.id.toString() && player.position.inSeconds > 0) {
          if (player.playing) {
            if (mounted) {
              setData(mt.id.toString());
            }
          }
        }
      }, onError: (Object e, StackTrace stackTrace) {
        ////print('A stream error occurred: $e');
      });

      // player1 = player;

      // _init();
      // player.pause();
      // player.seek(Duration.zero);
    }

    if (player.audioSource == null) {
      player.play();
      player.pause();
      context.read<MiniPlayerProvider>().changePlayer(
          nplayer: player, playing: false, nepisodes: episodes, isshow: false);
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      loaded = true;
    });
  }

  setData(id) {
    setState(() {
      current_id = id.toString();
    });
  }

  @override
  void dispose() {
    // _player.dispose();
    tabController.dispose();
    // _timer?.cancel();
    super.dispose();
  }

  playseek(i, index) async {
    Fluttertoast.showToast(msg: "Please wait while playing is loading...");
    await player.setAudioSource(_playlist);
    player.seek(Duration.zero, index: i);
    player.play();
    context.read<MiniPlayerProvider>().changePlayer(
        nplayer: player, playing: true, nepisodes: episodes, isshow: true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("current_id", index.toString());
    prefs.setString("playing_audio_id", widget.audio["id"].toString());
    current_audio_id = widget.audio["id"].toString();
    ////print(index);
    ////print("first_play");
    _init();
  }

  loadplayseekx(i, index) async {
    if (!player.playing) {
      await player.setAudioSource(_playlist);
    }

    player.seek(Duration.zero, index: i);
    player.play();
    context.read<MiniPlayerProvider>().changePlayer(
        nplayer: player, playing: true, nepisodes: episodes, isshow: true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("current_id", index.toString());

    prefs.setString("playing_audio_id", widget.audio["id"].toString());
    current_audio_id = widget.audio["id"].toString();
    // player.play();
  }

  loadplayseek(i, index) async {
    // await player.setAudioSource(_playlist);
    player.seek(Duration.zero, index: i);

    context.read<MiniPlayerProvider>().changePlayer(
        nplayer: player, playing: true, nepisodes: episodes, isshow: true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("current_id", index.toString());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      // _player.stop();
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  Future<bool> _willpop() {
    if (widget.type == "favorite") {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight,
              alignment: Alignment.bottomCenter,
              child: DashboardTabScreen(4)));
      return Future<bool>.value(false);
    } else if (widget.type == "downloads") {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight,
              alignment: Alignment.bottomCenter,
              child: MyDownloadListScreen()));
      return Future<bool>.value(false);
    } else if (widget.type == "dashboard") {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight,
              alignment: Alignment.bottomCenter,
              child: DashboardTabScreen(0)));
      return Future<bool>.value(false);
    } else if (widget.type == "search") {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight,
              alignment: Alignment.bottomCenter,
              child: SearchScreen(
                skey: widget.skey,
              )));
      return Future<bool>.value(false);
    } else if (widget.type == "category") {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight,
              alignment: Alignment.bottomCenter,
              child: DashboardTabScreen(1)));
      return Future<bool>.value(false);
    } else {
      return Future<bool>.value(true);
    }
  }

  editReview(dynamic mr) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight,
            alignment: Alignment.bottomCenter,
            child: EditReviewAudioScreen(
              widget.audio,
              widget.type,
              mr,
              isReviewed: (bool rv) {
                setState(() {
                  selectedIndex = 1;
                });
                loadData(1);
              },
            )));
  }

  delItem(dynamic mr) {
    setState(() {
      deleting = true;
    });
    ApiService()
        .delpostAudioReview(mr["id"].toString())
        .then((value) => confDel(value))
        .onError((error, stackTrace) => lepd());
  }

  lepd() {
    setState(() {
      deleting = false;
    });
    Fluttertoast.showToast(msg: "Unable to delete your review.");
  }

  confDel(d) {
    setState(() {
      deleting = false;
      selectedIndex = 1;
    });
    loadData(1);

    Fluttertoast.showToast(msg: "Your review has been deleted");
    Navigator.pop(context);
  }

  deleteReview(dynamic mr) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: 350,
            padding: EdgeInsets.symmetric(horizontal: 15),
            color: HexColor("16181f"),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close, color: Colors.white),
                    )
                  ],
                ),
                Icon(MdiIcons.trashCan,
                    size: 50, color: Colors.redAccent.withOpacity(0.8)),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  "Delete your review?",
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Once you delete your reviews, they cannot be retrieved.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      deleting
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              value: 10,
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: [0.0, 1.0],
                                    colors: [
                                      Colors.redAccent.shade400,
                                      Colors.blue,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                    ),
                                    padding: MaterialStatePropertyAll(
                                        EdgeInsets.symmetric(vertical: 10)),
                                    foregroundColor:
                                        MaterialStatePropertyAll(Colors.white),
                                    backgroundColor: MaterialStatePropertyAll(
                                        Colors.transparent)),
                                onPressed: () {
                                  if (!deleting) {
                                    setState(
                                      () {
                                        deleting = true;
                                      },
                                    );
                                    delItem(mr);
                                  }
                                },
                                child: Text(
                                  "Delete",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(25)),
                          child: TextButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                                padding: MaterialStatePropertyAll(
                                    EdgeInsets.symmetric(vertical: 10)),
                                foregroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                backgroundColor: MaterialStatePropertyAll(
                                    Colors.transparent)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ))
                    ],
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  custompop() {
    if (widget.type == "favorite") {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight,
              alignment: Alignment.bottomCenter,
              child: DashboardTabScreen(4)));
    } else if (widget.type == "dashboard") {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight,
              alignment: Alignment.bottomCenter,
              child: DashboardTabScreen(0)));
    } else if (widget.type == "search") {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight,
              alignment: Alignment.bottomCenter,
              child: SearchScreen(
                skey: widget.skey,
              )));
    } else if (widget.type == "category") {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight,
              alignment: Alignment.bottomCenter,
              child: DashboardTabScreen(1)));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/player_bg.png"), fit: BoxFit.cover)),
        child: WillPopScope(
          // canPop: true,

          onWillPop: _willpop,
          child: Scaffold(
            // bottomNavigationBar: BottomWidget(0),
            backgroundColor: Colors.transparent,
            appBar: AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                leading: BackButton(
                  onPressed: () {
                    //print("back Pressed");
                    custompop();
                  },
                ),
                title: Text(
                  widget.audio["title"].toString(),
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: Colors.transparent),
            body: ListView(
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Expanded(
                //   child:

                if (!loaded) ...{
                  for (int i = 0; i < 5; i++) ...{
                    Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        enabled: true,
                        child: SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                height: 16,
                              ),
                              ContentPlaceholder(
                                width: MediaQuery.of(context).size.width - 20,
                                lineType: ContentLineType.threeLines,
                              ),
                            ],
                          ),
                        )),
                  }
                },
                if (loaded) ...{
                  SizedBox(
                    height: 10,
                  ),
                  StreamBuilder<SequenceState?>(
                    stream: player.sequenceStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;

                      if (state?.sequence.isEmpty ?? true) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Text("Hello"),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(fi_image),
                                  fit: BoxFit.cover,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 122, 122, 122),
                                    blurRadius: 15,
                                    // offset: Offset(10, 10),
                                    // spreadRadius: 20,
                                  )
                                ],
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            // Text(metadata.album!,
                            //     style: GoogleFonts.poppins(
                            //         color: Colors.white,
                            //         fontSize: 16,
                            //         fontWeight: FontWeight.bold)),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                  child: Text(fi_title,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14, color: Colors.white)),
                                ))
                          ],
                        );
                      }
                      final metadata = state!.currentSource!.tag as MediaItem;
                      ////print(metadata.id);
                      ////print("metadata");

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Text("Hello"),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    itemIds.contains(metadata.id.toString())
                                        ? player.playing
                                            ? metadata.artUri.toString()
                                            : (fi_image == ""
                                                ? metadata.artUri.toString()
                                                : fi_image)
                                        : fi_image),
                                fit: BoxFit.cover,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 122, 122, 122),
                                  blurRadius: 15,
                                  // offset: Offset(10, 10),
                                  // spreadRadius: 20,
                                )
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 10,
                          ),
                          // Text(metadata.album!,
                          //     style: GoogleFonts.poppins(
                          //         color: Colors.white,
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.bold)),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Center(
                                child: Text(
                                    itemIds.contains(metadata.id.toString())
                                        ? player.playing
                                            ? metadata.title.toString()
                                            : (fi_title == ""
                                                    ? metadata.title.toString()
                                                    : fi_title) +
                                                ""
                                        : fi_title,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        fontSize: 14, color: Colors.white)),
                              ))
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: ControlButtons(
                      player,
                      episodes,
                      _playlist,
                      itemIds,
                      current_id,
                      audio: widget.audio,
                      setCurrent: (idx, ida) async {
                        //print(idx);
                        //print("Ye current");
                        setState(() {
                          current_id = idx;
                          current_audio_id = ida;
                          fi_image = "";
                          fi_title = "";
                        });
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString("current_id", idx.toString());
                        prefs.setString("playing_audio_id", ida.toString());
                      },
                    ),
                  ),
                  StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return SeekBar(
                        audio: widget.audio,
                        player: player,
                        itemIds: itemIds,
                        current_id: current_id,
                        duration: positionData?.duration ?? Duration.zero,
                        position: positionData?.position ?? Duration.zero,
                        bufferedPosition:
                            positionData?.bufferedPosition ?? Duration.zero,
                        onChangeEnd: (newPosition) {
                          player.seek(newPosition);
                        },
                      );
                    },
                  ),
                  DefaultTabController(
                    initialIndex: widget.index,
                    length: 3, // Number of tabs
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TabBar(
                          indicatorColor: Colors.redAccent,
                          labelColor: Colors.redAccent,
                          unselectedLabelColor: Colors.white,
                          onTap: (int index) {
                            setState(() {
                              selectedIndex = index;
                              tabController.animateTo(index);
                            });
                          },
                          labelStyle: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          tabs: [
                            Tab(
                              text: "Episodes",
                            ),
                            Tab(
                              text: "Reviews",
                            ),
                            Tab(
                              text: "About",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - 350,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        selectedIndex != 0
                            ? SizedBox()
                            : StreamBuilder<SequenceState?>(
                                stream: player.sequenceStateStream,
                                builder: (context, snapshot) {
                                  final state = snapshot.data;

                                  if (state?.sequence.isEmpty ?? true) {
                                    return Container(
                                      child: Column(
                                          // shrinkWrap: true,
                                          children: [
                                            for (int i = 0;
                                                i < eepisodes.length;
                                                i++) ...{
                                              InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  overlayColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.transparent),
                                                  onTap: () async {
                                                    if (eepisodes[i].tag.extras[
                                                                'type'] ==
                                                            "free" ||
                                                        subscribed) {
                                                      setState(() {
                                                        current_audio_id ==
                                                            widget.audio["id"]
                                                                .toString();
                                                        current_id =
                                                            eepisodes[i]
                                                                .tag
                                                                .id
                                                                .toString();
                                                      });
                                                      // player.pause();
                                                      if (!player.playing) {
                                                        loadplayseekx(
                                                            i,
                                                            eepisodes[i]
                                                                .tag
                                                                .id
                                                                .toString());
                                                      } else {
                                                        if (player
                                                                .sequenceState !=
                                                            null) {
                                                          final metadatax = player
                                                              .sequenceState!
                                                              .currentSource!
                                                              .tag as MediaItem;
                                                          if (itemIds.contains(
                                                              metadatax.id
                                                                  .toString())) {
                                                            loadplayseekx(
                                                                i,
                                                                eepisodes[i]
                                                                    .tag
                                                                    .id
                                                                    .toString());
                                                          } else {
                                                            player.pause();
                                                            playseek(
                                                                i,
                                                                eepisodes[i]
                                                                    .tag
                                                                    .id
                                                                    .toString());
                                                          }
                                                        } else {
                                                          player.pause();
                                                          playseek(
                                                              i,
                                                              eepisodes[i]
                                                                  .tag
                                                                  .id
                                                                  .toString());
                                                        }
                                                      }
                                                    } else {
                                                      //pop for purchase
                                                      purchase();
                                                    }
                                                  },
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 15,
                                                            vertical: 5),
                                                    child: Row(children: [
                                                      Container(
                                                        width: 35,
                                                        height: 35,
                                                        // padding: EdgeInsets.symmetric(
                                                        //     horizontal: 12, vertical: 5),
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(30),
                                                            border: Border.all(
                                                                color: current_audio_id == widget.audio["id"].toString() && 0 == i
                                                                    ? Colors.redAccent
                                                                    : eepisodes[i].tag.extras['type'] == "free" || subscribed
                                                                        ? Colors.white
                                                                        : Colors.redAccent)),
                                                        child: Center(
                                                          child: eepisodes[i]
                                                                          .tag
                                                                          .extras['type'] ==
                                                                      "free" ||
                                                                  subscribed
                                                              ? Text(
                                                                  "${i + 1}",
                                                                  style: GoogleFonts.poppins(
                                                                      color: current_audio_id == widget.audio["id"].toString() &&
                                                                              0 ==
                                                                                  i
                                                                          ? Colors
                                                                              .redAccent
                                                                          : Colors
                                                                              .white),
                                                                )
                                                              : Icon(
                                                                  MdiIcons.lock,
                                                                  size: 20,
                                                                  color: Colors
                                                                      .redAccent
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                        ),
                                                      ),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              100,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                eepisodes[i]
                                                                    .tag
                                                                    .title
                                                                    .toString(),
                                                                style: GoogleFonts.poppins(
                                                                    color: current_audio_id == widget.audio["id"].toString() &&
                                                                            0 ==
                                                                                i
                                                                        ? Colors
                                                                            .redAccent
                                                                        : Colors
                                                                            .white,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              SizedBox(
                                                                height: 3.h,
                                                              ),
                                                              Row(

                                                                children: [
                                                                  Icon(
                                                                    MdiIcons
                                                                        .clock,
                                                                    size: 18,
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.5),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 3.w,
                                                                  ),
                                                                  Text(
                                                                    "${eepisodes[i].duration?.inMinutes}.${eepisodes[i].duration!.inSeconds % 60} mins",
                                                                    style: GoogleFonts.poppins(
                                                                        color: current_audio_id == widget.audio["id"].toString() && 0 == i
                                                                            ? Colors
                                                                                .redAccent
                                                                            : TEXT_WHITE_SHADE,
                                                                        fontSize:
                                                                            14.sp),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 3.h,
                                                              ),
                                                            ],
                                                          )),
                                                      if (eepisodes[i]
                                                                      .tag
                                                                      .extras[
                                                                  'type'] ==
                                                              "free" ||
                                                          subscribed) ...{
                                                        if (itedmDownloads
                                                            .contains(eepisodes[
                                                                    i]
                                                                .tag
                                                                .id
                                                                .toString())) ...{
                                                          Container(
                                                            child: Icon(
                                                                Icons
                                                                    .cloud_done,
                                                                color: Colors
                                                                    .white),
                                                          )
                                                        } else ...{
                                                          InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              overlayColor:
                                                                  MaterialStatePropertyAll(
                                                                      Colors
                                                                          .transparent),
                                                              onTap: () {
                                                                downloadFile(
                                                                    episodes[i]
                                                                        .child
                                                                        .uri
                                                                        .toString(),
                                                                    eepisodes[i]
                                                                            .tag
                                                                            .id +
                                                                        ".mp3",
                                                                    eepisodes[i]
                                                                        .tag
                                                                        .id
                                                                        .toString());
                                                              },
                                                              child: Container(
                                                                height: 25,
                                                                width: 25,
                                                                child: downloadingList.contains(
                                                                        eepisodes[i]
                                                                            .tag
                                                                            .id
                                                                            .toString())
                                                                    ? AnimateIcon(
                                                                        key:
                                                                            UniqueKey(),
                                                                        onTap:
                                                                            () {},
                                                                        iconType:
                                                                            IconType.continueAnimation,
                                                                        height:
                                                                            70,
                                                                        width:
                                                                            70,
                                                                        color: Colors
                                                                            .white,
                                                                        animateIcon:
                                                                            AnimateIcons.downArrow,
                                                                      )
                                                                    : Icon(
                                                                        Icons
                                                                            .download_for_offline,
                                                                        color: Colors
                                                                            .white),
                                                              ))
                                                        }
                                                      }
                                                    ]),
                                                  )),
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 30,
                                                    vertical: 10),
                                                height: 1,
                                                decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.5)),
                                              )
                                            },
                                            SizedBox(
                                              height: 150,
                                            )
                                          ]),
                                    );
                                  }
                                  final current_index = state!.currentIndex;
                                  return Container(
                                    child: Column(
                                        // shrinkWrap: true,
                                        children: [
                                          for (int i = 0;
                                              i < eepisodes.length;
                                              i++) ...{
                                            InkWell(
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                overlayColor:
                                                    MaterialStatePropertyAll(
                                                        Colors.transparent),
                                                onTap: () async {
                                                  if (eepisodes[i]
                                                              .tag
                                                              .extras['type'] ==
                                                          "free" ||
                                                      subscribed) {
                                                    setState(() {
                                                      current_audio_id ==
                                                          widget.audio["id"]
                                                              .toString();
                                                      current_id = eepisodes[i]
                                                          .tag
                                                          .id
                                                          .toString();
                                                    });
                                                    // player.pause();
                                                    if (!player.playing) {
                                                      loadplayseekx(
                                                          i,
                                                          eepisodes[i]
                                                              .tag
                                                              .id
                                                              .toString());
                                                    } else {
                                                      if (player
                                                              .sequenceState !=
                                                          null) {
                                                        final metadatax = player
                                                            .sequenceState!
                                                            .currentSource!
                                                            .tag as MediaItem;
                                                        if (itemIds.contains(
                                                            metadatax.id
                                                                .toString())) {
                                                          loadplayseekx(
                                                              i,
                                                              eepisodes[i]
                                                                  .tag
                                                                  .id
                                                                  .toString());
                                                        } else {
                                                          player.pause();
                                                          playseek(
                                                              i,
                                                              eepisodes[i]
                                                                  .tag
                                                                  .id
                                                                  .toString());
                                                        }
                                                      } else {
                                                        player.pause();
                                                        playseek(
                                                            i,
                                                            eepisodes[i]
                                                                .tag
                                                                .id
                                                                .toString());
                                                      }
                                                    }
                                                  } else {
                                                    //pop for purchase
                                                    purchase();
                                                  }
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                                  child: Row(children: [
                                                    Container(
                                                      width: 35,
                                                      height: 35,
                                                      // padding: EdgeInsets.symmetric(
                                                      //     horizontal: 12, vertical: 5),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          border: Border.all(
                                                              color: current_audio_id ==
                                                                          widget.audio["id"]
                                                                              .toString() &&
                                                                      current_index ==
                                                                          i
                                                                  ? Colors
                                                                      .redAccent
                                                                  : eepisodes[i].tag.extras['type'] ==
                                                                              "free" ||
                                                                          subscribed
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .redAccent)),
                                                      child: Center(
                                                        child: eepisodes[i]
                                                                            .tag
                                                                            .extras[
                                                                        'type'] ==
                                                                    "free" ||
                                                                subscribed
                                                            ? Text(
                                                                "${i + 1}",
                                                                style: GoogleFonts.poppins(
                                                                    color: current_audio_id == widget.audio["id"].toString() &&
                                                                            current_index ==
                                                                                i
                                                                        ? Colors
                                                                            .redAccent
                                                                        : Colors
                                                                            .white),
                                                              )
                                                            : Icon(
                                                                MdiIcons.lock,
                                                                size: 20,
                                                                color: Colors
                                                                    .redAccent
                                                                    .withOpacity(
                                                                        0.5),
                                                              ),
                                                      ),
                                                    ),
                                                    Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            100,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              eepisodes[i]
                                                                  .tag
                                                                  .title
                                                                  .toString(),
                                                              style: GoogleFonts.poppins(
                                                                  color: current_audio_id ==
                                                                              widget.audio["id"]
                                                                                  .toString() &&
                                                                          current_index ==
                                                                              i
                                                                      ? Colors
                                                                          .redAccent
                                                                      : Colors
                                                                          .white,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  MdiIcons
                                                                      .clock,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Text(
                                                                  "${eepisodes[i].duration?.inMinutes}.${eepisodes[i].duration!.inSeconds % 60} mins",
                                                                  style: GoogleFonts.poppins(
                                                                      color: current_audio_id == widget.audio["id"].toString() &&
                                                                              current_index ==
                                                                                  i
                                                                          ? Colors
                                                                              .redAccent
                                                                          : TEXT_WHITE_SHADE,
                                                                      fontSize:
                                                                          14),
                                                                )
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                          ],
                                                        )),
                                                    if (eepisodes[i].tag.extras[
                                                                'type'] ==
                                                            "free" ||
                                                        subscribed) ...{
                                                      if (itedmDownloads
                                                          .contains(eepisodes[i]
                                                              .tag
                                                              .id
                                                              .toString())) ...{
                                                        Container(
                                                          child: Icon(
                                                              Icons.cloud_done,
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      } else ...{
                                                        InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            overlayColor:
                                                                MaterialStatePropertyAll(
                                                                    Colors
                                                                        .transparent),
                                                            onTap: () {
                                                              downloadFile(
                                                                  episodes[i]
                                                                      .child
                                                                      .uri
                                                                      .toString(),
                                                                  eepisodes[i]
                                                                          .tag
                                                                          .id +
                                                                      ".mp3",
                                                                  eepisodes[i]
                                                                      .tag
                                                                      .id
                                                                      .toString());
                                                            },
                                                            child: Container(
                                                              height: 25,
                                                              width: 25,
                                                              child: downloadingList.contains(
                                                                      eepisodes[
                                                                              i]
                                                                          .tag
                                                                          .id
                                                                          .toString())
                                                                  ? AnimateIcon(
                                                                      key:
                                                                          UniqueKey(),
                                                                      onTap:
                                                                          () {},
                                                                      iconType:
                                                                          IconType
                                                                              .continueAnimation,
                                                                      height:
                                                                          70,
                                                                      width: 70,
                                                                      color: Colors
                                                                          .white,
                                                                      animateIcon:
                                                                          AnimateIcons
                                                                              .downArrow,
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .download_for_offline,
                                                                      color: Colors
                                                                          .white),
                                                            ))
                                                      }
                                                    }
                                                  ]),
                                                )),
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 30, vertical: 10),
                                              height: 1,
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.5)),
                                            )
                                          },
                                          SizedBox(
                                            height: 150,
                                          )
                                        ]),
                                  );
                                }),
                        selectedIndex != 1
                            ? SizedBox()
                            : Container(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                            double.parse(widget
                                                                    .audio[
                                                                        "ratings"]
                                                                    .toString())
                                                                .toStringAsFixed(
                                                                    1)
                                                                .toString(),
                                                            style: GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(" / ",
                                                            style: GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.6))),
                                                        Text(
                                                          "5.0",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.6)),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: RatingBar.builder(
                                                  initialRating: double.parse(
                                                      widget.audio["ratings"]
                                                          .toString()),
                                                  minRating: double.parse(widget
                                                      .audio["ratings"]
                                                      .toString()),
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemSize: 25,
                                                  unratedColor: Colors.grey,
                                                  // itemCount: 5,
                                                  // glow: true,
                                                  // glowColor: Colors.amber,
                                                  glow: false,
                                                  ignoreGestures: true,
                                                  glowRadius: 5,
                                                  maxRating: double.parse(widget
                                                      .audio["ratings"]
                                                      .toString()),
                                                  itemPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 4.0),
                                                  itemBuilder: (context, _) =>
                                                      Icon(
                                                    MdiIcons.star,
                                                    size: 15,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate: (rating) {
                                                    ////print(rating);
                                                  },
                                                ),
                                              )
                                            ],
                                          )),
                                      InkWell(
                                          onTap: () {
                                            if (yourRating == null) {
                                              // Navigator.pop(context);
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType
                                                          .leftToRight,
                                                      child: ReviewAudioScreen(
                                                        widget.audio,
                                                        widget.type,
                                                        isReviewed: (bool rv) {
                                                          if (rv) {
                                                            setState(() {
                                                              selectedIndex = 1;
                                                            });
                                                            loadData(1);
                                                          }
                                                        },
                                                      )));
                                            }
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: THEME_BLACK
                                                      .withOpacity(0.5)),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 15),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                      child: Text(
                                                    "You Rated",
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  )),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20),
                                                    child: RatingBar.builder(
                                                      initialRating: yourRating !=
                                                              null
                                                          ? double.parse(
                                                              yourRating[
                                                                      "rating"]
                                                                  .toString())
                                                          : 0,
                                                      minRating: 0,
                                                      direction:
                                                          Axis.horizontal,
                                                      allowHalfRating: true,
                                                      itemSize: 25,
                                                      ignoreGestures: true,
                                                      unratedColor: Colors.grey,
                                                      // itemCount: 5,
                                                      // glow: true,
                                                      // glowColor: Colors.amber,
                                                      glow: false,
                                                      glowRadius: 5,
                                                      maxRating: yourRating !=
                                                              null
                                                          ? double.parse(
                                                              yourRating[
                                                                      "rating"]
                                                                  .toString())
                                                          : 0,
                                                      itemPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.0),
                                                      itemBuilder:
                                                          (context, _) => Icon(
                                                        MdiIcons.star,
                                                        size: 15,
                                                        color: Colors.amber,
                                                      ),
                                                      onRatingUpdate: (rating) {
                                                        ////print(rating);
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ))),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: Row(children: [
                                          Text(
                                            "Reviews",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 18),
                                          )
                                        ]),
                                      ),
                                      if (myrate != null) ...{
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  editReview(myrate);
                                                },
                                                child: Icon(MdiIcons.pencil,
                                                    size: 25,
                                                    color: Colors.white),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  deleteReview(myrate);
                                                },
                                                child: Icon(MdiIcons.trashCan,
                                                    size: 25,
                                                    color: Colors.redAccent
                                                        .withOpacity(0.8)),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Row(children: [
                                            Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                          ApiConstants
                                                                  .storagePATH +
                                                              "/author/" +
                                                              myrate["user"][
                                                                      "profile_photo"]
                                                                  .toString()))),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              myrate["user"]["name"].toString(),
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white),
                                            )
                                          ]),
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    RatingBar.builder(
                                                      initialRating:
                                                          double.parse(
                                                              myrate["rating"]
                                                                  .toString()),
                                                      minRating: 0,
                                                      direction:
                                                          Axis.horizontal,
                                                      allowHalfRating: true,
                                                      itemSize: 20,
                                                      ignoreGestures: true,
                                                      unratedColor: Colors.grey,
                                                      glow: false,
                                                      glowRadius: 5,
                                                      maxRating: double.parse(
                                                          myrate["rating"]
                                                              .toString()),
                                                      itemPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 2.0),
                                                      itemBuilder:
                                                          (context, _) => Icon(
                                                        MdiIcons.star,
                                                        size: 15,
                                                        color: Colors.amber,
                                                      ),
                                                      onRatingUpdate: (rating) {
                                                        ////print(rating);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 20),
                                                child: Text(
                                                  DateFormat.yMMMMd().format(
                                                      DateTime.parse(
                                                          myrate["updated_at"]
                                                              .toString())),
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                ),
                                              )
                                            ]),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Text(
                                            myrate["comment"].toString(),
                                            style: GoogleFonts.poppins(
                                                color: Colors.white),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 15),
                                          height: 2,
                                          decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.5)),
                                        )
                                      },
                                      for (int i = 0;
                                          i < ratingList.length;
                                          i++) ...{
                                        if (ratingList[i]["user"] != null) ...{
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Row(children: [
                                              Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(ApiConstants
                                                                .storagePATH +
                                                            "/author/" +
                                                            ratingList[i]
                                                                        ["user"]
                                                                    [
                                                                    "profile_photo"]
                                                                .toString()))),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                ratingList[i]["user"]["name"]
                                                    .toString(),
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white),
                                              )
                                            ]),
                                          ),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      RatingBar.builder(
                                                        initialRating: double
                                                            .parse(ratingList[i]
                                                                    ["rating"]
                                                                .toString()),
                                                        minRating: 0,
                                                        direction:
                                                            Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemSize: 20,
                                                        ignoreGestures: true,
                                                        unratedColor:
                                                            Colors.grey,
                                                        glow: false,
                                                        glowRadius: 5,
                                                        maxRating: double.parse(
                                                            ratingList[i]
                                                                    ["rating"]
                                                                .toString()),
                                                        itemPadding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    2.0),
                                                        itemBuilder:
                                                            (context, _) =>
                                                                Icon(
                                                          MdiIcons.star,
                                                          size: 15,
                                                          color: Colors.amber,
                                                        ),
                                                        onRatingUpdate:
                                                            (rating) {
                                                          ////print(rating);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 20),
                                                  child: Text(
                                                    DateFormat.yMMMMd().format(
                                                        DateTime.parse(
                                                            ratingList[i][
                                                                    "created_at"]
                                                                .toString())),
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                )
                                              ]),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Text(
                                              ratingList[i]["comment"]
                                                  .toString(),
                                              textAlign: TextAlign.start,
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 15),
                                            height: 2,
                                            decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.5)),
                                          )
                                        },
                                      },
                                      SizedBox(
                                        height: 150,
                                      )
                                    ]),
                              ),
                        selectedIndex != 2
                            ? SizedBox()
                            : Container(
                                margin: EdgeInsets.only(bottom: 150),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Html(
                                    data:
                                        widget.audio["description"].toString(),
                                    shrinkWrap: true,
                                    style: {
                                      "body": Style(
                                          fontSize: FontSize(14.0),
                                          textAlign: TextAlign.justify,
                                          // fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    }),
                              ),
                      ],
                    ),
                  )
                }
              ],
            ),
          ),
        ));
  }
}

class ControlButtons extends StatefulWidget {
  final AudioPlayer player;
  final List<ClippingAudioSource> episodes;
  ConcatenatingAudioSource playlist;
  dynamic audio;
  List<String> itemIds;
  String current_id;
  Function setCurrent;
  ControlButtons(
      this.player, this.episodes, this.playlist, this.itemIds, this.current_id,
      {required this.setCurrent, this.audio, Key? key})
      : super(key: key);
  @override
  State<ControlButtons> createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  playNow() async {
    ConcatenatingAudioSource _playlist =
        ConcatenatingAudioSource(children: widget.episodes);

    try {
      await player.setAudioSource(_playlist);
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      ////print("Error loading playlist: $e");
      ////print(stackTrace);
    }
  }

  viewsCount() {
    // print("Views count+++");
    ApiService()
        .viewsCountAudio(widget.audio["id"].toString())
        .then((value) {})
        .onError((error, stackTrace) {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Opens volume slider dialog

        StreamBuilder<bool>(
          stream: player.shuffleModeEnabledStream,
          builder: (context, snapshot) {
            final shuffleModeEnabled = snapshot.data ?? false;
            return IconButton(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: shuffleModeEnabled
                  ? const Icon(
                      Icons.shuffle,
                      color: Colors.redAccent,
                      size: 30,
                    )
                  : const Icon(Icons.shuffle, color: Colors.white, size: 30),
              onPressed: () async {
                if (widget.itemIds.contains(widget.current_id)) {
                  final enable = !shuffleModeEnabled;
                  if (enable) {
                    await player.shuffle();
                  }
                  await player.setShuffleModeEnabled(enable);
                }
              },
            );
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) {
            return IconButton(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.skip_previous,
                  color: widget.itemIds.contains(widget.current_id)
                      ? (player.hasPrevious ? Colors.white : Colors.grey)
                      : Colors.grey,
                  size: 30),
              onPressed: () async {
                if (widget.itemIds.contains(widget.current_id)) {
                  int idx = -1;
                  for (int i = 0; i < widget.episodes.length; i++) {
                    if (widget.episodes[i].tag.id.toString() ==
                        widget.current_id) {
                      idx = i - 1;
                    }
                  }

                  if (idx >= 0) {
                    widget.setCurrent(widget.episodes[idx].tag.id.toString(),
                        widget.audio["id"].toString());
                  }
                  await player.seekToPrevious();
                }
              },
            );
          },
        ),

        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 40.0,
                height: 40.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: const Icon(
                  MdiIcons.playCircle,
                  color: Colors.white,
                  weight: 1,
                ),
                iconSize: 40.0,
                onPressed: () {
                  //print("playc");
                  if (!widget.itemIds.contains(widget.current_id)) {
                    widget.setCurrent(widget.itemIds[0].toString(),
                        widget.audio["id"].toString());

                    //print("ye cu");
                    playNow();
                  }

                  // player1 = player;
                  // player1.stop();
                  player.play();

                  context.read<MiniPlayerProvider>().changePlayer(
                      nplayer: player,
                      playing: true,
                      nepisodes: widget.episodes,
                      isshow: true);
                  viewsCount();
                },
              );
            } else if (processingState != ProcessingState.completed) {
              return widget.itemIds.contains(widget.current_id)
                  ? IconButton(
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: const Icon(
                        Icons.pause,
                        color: Colors.white,
                      ),
                      iconSize: 40.0,
                      onPressed: () {
                        ////print("pause");
                        ///
                        widget.setCurrent(
                            widget.current_id, widget.audio["id"].toString());
                        player.pause();
                        context.read<MiniPlayerProvider>().changePlayer(
                            nplayer: player,
                            playing: false,
                            nepisodes: widget.episodes,
                            isshow: true);
                      },
                    )
                  : IconButton(
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: const Icon(
                        MdiIcons.playCircle,
                        color: Colors.white,
                        weight: 1,
                      ),
                      iconSize: 40.0,
                      onPressed: () {
                        ////print("play122345");
                        widget.setCurrent(widget.itemIds[0].toString(),
                            widget.audio["id"].toString());
                        playNow();
                        //12345
                        // player1 = player;
                        // player1.stop();
                        player.play();

                        context.read<MiniPlayerProvider>().changePlayer(
                            nplayer: player,
                            playing: true,
                            nepisodes: widget.episodes,
                            isshow: true);
                        viewsCount();
                      },
                    );
            } else {
              return IconButton(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: const Icon(
                  MdiIcons.playCircle,
                  color: Colors.white,
                  weight: 1,
                ),
                iconSize: 40.0,
                onPressed: () {
                  if (widget.itemIds.contains(widget.current_id)) {
                    widget.setCurrent(
                        widget.current_id, widget.audio["id"].toString());
                    player.seek(Duration.zero);
                    ////print("Play data data");
                    viewsCount();
                  }
                },
              );
            }
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) {
            return IconButton(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.skip_next,
                  color: widget.itemIds.contains(widget.current_id)
                      ? (player.hasNext ? Colors.white : Colors.grey)
                      : Colors.grey,
                  size: 30),
              onPressed: () async {
                if (widget.itemIds.contains(widget.current_id)) {
                  int idx = -1;
                  for (int i = 0; i < widget.episodes.length; i++) {
                    if (widget.episodes[i].tag.id.toString() ==
                        widget.current_id) {
                      idx = i + 1;
                    }
                  }
                  if (idx < widget.episodes.length) {
                    widget.setCurrent(widget.episodes[idx].tag.id.toString(),
                        widget.audio["id"].toString());
                  }

                  // ////print(episodes[idx].tag.id.toString());

                  await player.seekToNext();
                }
              },
            );
          },
        ),

        // IconButton(
        //   icon: const Icon(
        //     Icons.repeat,
        //     color: Colors.white,
        //   ),
        //   onPressed: () {},
        // ),

        StreamBuilder<LoopMode>(
          stream: player.loopModeStream,
          builder: (context, snapshot) {
            final loopMode = snapshot.data ?? LoopMode.off;
            const icons = [
              Icon(Icons.repeat, color: Colors.white, size: 30),
              Icon(Icons.repeat, color: Colors.red, size: 30),
              Icon(
                Icons.repeat_one,
                color: Colors.orange,
                size: 30,
              ),
            ];
            const cycleModes = [
              LoopMode.off,
              LoopMode.all,
              LoopMode.one,
            ];
            final index = cycleModes.indexOf(loopMode);
            return IconButton(
              icon: icons[index],
              onPressed: () {
                player.setLoopMode(cycleModes[
                    (cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
              },
            );
          },
        ),

        // Opens speed slider dialog
        // StreamBuilder<double>(
        //   stream: player.speedStream,
        //   builder: (context, snapshot) => IconButton(
        //     icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
        //         style: const TextStyle(fontWeight: FontWeight.bold)),
        //     onPressed: () {
        //       showSliderDialog(
        //         context: context,
        //         title: "Adjust speed",
        //         divisions: 10,
        //         min: 0.5,
        //         max: 1.5,
        //         value: player.speed,
        //         stream: player.speedStream,
        //         onChanged: player.setSpeed,
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}
