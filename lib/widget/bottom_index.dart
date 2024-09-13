import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sunozara/constants.dart';
import 'package:sunozara/dashboard.dart';
import 'package:sunozara/provider/miniplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import '../articles/list.dart';
import '../audio/cat_list.dart';
import '../audio/category_item.dart';
import '../audio/favorite.dart';
import '../audio/player.dart';
import '../audio/player_common_mini.dart';
import '../product/product_list.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';

class BottomWidgetIndex extends StatefulWidget {
  int sid;
  String mode;
  Function getIndex;
  BottomWidgetIndex(this.sid,
      {this.mode = "dark", required this.getIndex, super.key});

  @override
  State<BottomWidgetIndex> createState() => _BottomWidgetIndexState();
}

class _BottomWidgetIndexState extends State<BottomWidgetIndex> {
  int _selectedIndex = 0;
  final service = FlutterBackgroundService();
  List<dynamic> items = [];
  bool loaded = false;
  bool itemLoaded = false;
  List<BottomNavigationBarItem> itemsData = [];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      widget.getIndex(index);
    });

    // if (widget.sid != index || index == 2) {
    //   Navigator.pushAndRemoveUntil(
    //       context,
    //       PageTransition(
    //           type: PageTransitionType.leftToRight,
    //           alignment: Alignment.bottomCenter,
    //           child: items[index]),
    //       (route) => false);
    // }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _selectedIndex = widget.sid;
    });

    loadConfig();
  }

  loadConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool is_audio_enable = prefs.getBool("is_audio_enable")!;
    bool is_book_enable = prefs.getBool("is_book_enable")!;
    bool is_article_enable = prefs.getBool("is_article_enable")!;

    setState(() {
      loaded = true;
      items = [
        DashboardScreen(
          getIndex: (int ix) {
            setState(() {
              _selectedIndex = ix;
            });
          },
          getCat: () {},
        ),
        if (is_audio_enable) ...{
          CatItemListScreen(
            null,
            getIndex: (int ix) {
              setState(() {
                _selectedIndex = ix;
              });
            },
          ),
        },
        if (is_article_enable) ...{
          ArticleListSCreen(
            getIndex: (int ix) {
              setState(() {
                _selectedIndex = ix;
              });
            },
          ),
        },
        if (is_book_enable) ...{
          ProductListScreen(
            getIndex: (int ix) {
              setState(() {
                _selectedIndex = ix;
              });
            },
          ),
        },
        if (is_audio_enable) ...{
          MyFavAudioList(
            getIndex: (int ix) {
              setState(() {
                _selectedIndex = ix;
              });
            },
          )
        }
      ];
    });
    setState(() {
      itemsData = <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset(
            "assets/home.png",
            height: 20,
          ),
          activeIcon: Image.asset(
            "assets/home.png",
            height: 20,
            color: GR1,
          ),
          label: 'Home',
        ),
        if (is_audio_enable) ...{
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/ab.png",
              height: 20,
            ),
            activeIcon: Image.asset(
              "assets/ab.png",
              height: 20,
              color: GR1,
            ),
            label: 'Audio',
          ),
        },
        if (is_article_enable) ...{
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/article.png",
              height: 20,
            ),
            activeIcon: Image.asset(
              "assets/article.png",
              height: 20,
              color: GR1,
            ),
            label: 'Write',
          ),
        },
        if (is_book_enable) ...{
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/prd.png",
              height: 20,
            ),
            activeIcon: Image.asset(
              "assets/prd.png",
              height: 20,
              color: GR1,
            ),
            label: 'Buy',
          ),
        },
        if (is_audio_enable) ...{
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/fav.png",
              height: 20,
            ),
            activeIcon: Image.asset(
              "assets/fav.png",
              height: 20,
              color: GR1,
            ),
            label: 'Favorite',
          ),
        }
      ];
      itemLoaded = true;
    });

    player.playbackEventStream.listen((event) {
      if (player.sequenceState != null) {
        if (mounted) {
          if (player.playing) {
            // print("Playing...");
            playerInfo(true, true);
          } else {
            playerInfo(false, context.read<MiniPlayerProvider>().isshow);
          }
        }
      }
    }, onError: (Object e, StackTrace stackTrace) {
      //print('A stream error occurred: $e');
    });
  }

  playerInfo(bool t, bool s) {
    context
        .read<MiniPlayerProvider>()
        .closePlayer(nplayer: player, playing: t, isshow: s);
  }

  pervId() async {
    // if (!player.playing) {
    List<ClippingAudioSource> episodes =
        context.read<MiniPlayerProvider>().episodes;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? current_id = prefs.getString("current_id");
    int index = -1;

    for (int i = 0; i < episodes.length; i++) {
      final mx = episodes[i].tag as MediaItem;
      print(mx.id.toString());
      print("hxn");
      if (mx.id.toString() == current_id) {
        index = i;
      }
    }
    print(index);
    print("hxn1");
    if (index > 0) {
      final mx1 = episodes[index - 1].tag as MediaItem;
      print(mx1.id.toString());
      prefs.setString("current_id", mx1.id.toString());
    }
    // }
  }

  nextId() async {
    // if (!player.playing) {
    List<ClippingAudioSource> episodes =
        context.read<MiniPlayerProvider>().episodes;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? current_id = prefs.getString("current_id");
    int index = -1;

    for (int i = 0; i < episodes.length; i++) {
      final mx = episodes[i].tag as MediaItem;
      print(mx.id.toString());
      print("hxn");
      if (mx.id.toString() == current_id) {
        index = i;
      }
    }
    print(index);
    print("hxn1n");
    if (index < episodes.length - 1) {
      final mx1 = episodes[index + 1].tag as MediaItem;
      print(mx1.id.toString());
      prefs.setString("current_id", mx1.id.toString());
    }

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer<MiniPlayerProvider>(builder: (context, mp, child) {
          return mp.isshow
              ? Container(
                  // height: 80,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: StreamBuilder<SequenceState?>(
                      stream: player.sequenceStateStream,
                      builder: (context, snapshot) {
                        final state = snapshot.data;

                        if (state != null) {
                          if (state.sequence.isEmpty) {
                            return const SizedBox();
                          }
                        } else {
                          return const SizedBox();
                        }
                        if (state.currentSource == null) {
                          return const SizedBox();
                        }
                        final metadata = state.currentSource!.tag as MediaItem;
                        // //print(metadata.extras);

                        return InkWell(
                            overlayColor:
                                MaterialStatePropertyAll(Colors.transparent),
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Colors.blue,
                                      Colors.redAccent,
                                    ],
                                  ),
                                  // color: THEME_BLACK.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(2)),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                        overlayColor: MaterialStatePropertyAll(
                                            Colors.transparent),
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .leftToRight,
                                                  child: AudioPlayerScreen(
                                                      metadata.extras?["audio"],
                                                      "dashboard")));
                                        },
                                        child: SizedBox(
                                          width: 50,
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            margin: EdgeInsets.only(right: 10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            metadata.artUri
                                                                .toString()))),
                                          ),
                                        )),
                                    InkWell(
                                        overlayColor: MaterialStatePropertyAll(
                                            Colors.transparent),
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .leftToRight,
                                                  child: AudioPlayerScreen(
                                                      metadata.extras?["audio"],
                                                      "dashboard")));
                                        },
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              200,
                                          child: Text(
                                            metadata.title,
                                            maxLines: 2,
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        )),
                                    Container(
                                        margin: EdgeInsets.only(right: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                mp.playerd.hasPrevious
                                                    ? SizedBox(
                                                        width: 30,
                                                        child: Container(
                                                          child: IconButton(
                                                            splashColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            icon: Icon(
                                                              Icons
                                                                  .chevron_left,
                                                              color:
                                                                  Colors.white,
                                                              size: 30,
                                                            ),
                                                            onPressed: () {
                                                              if (mp.playerd
                                                                      .loopMode ==
                                                                  LoopMode
                                                                      .one) {
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            "Audio is in loop mode. Can not go back.");
                                                              } else {
                                                                pervId();
                                                                mp.playerd
                                                                    .seekToPrevious();
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: 30,
                                                      ),
                                                SizedBox(
                                                  width: 30,
                                                  child: Container(
                                                    child: IconButton(
                                                      splashColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      icon: Icon(
                                                        mp.playerd.playing
                                                            ? Icons.pause
                                                            : Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                      onPressed: () {
                                                        if (mp
                                                            .playerd.playing) {
                                                          mp.playerd.pause();
                                                          context
                                                              .read<
                                                                  MiniPlayerProvider>()
                                                              .closePlayer(
                                                                  nplayer: mp
                                                                      .playerd,
                                                                  playing:
                                                                      false,
                                                                  isshow: true);
                                                          // context.read<MiniPlayerProvider>().changePlayer(nplayer. player. playing: false, nepisodes: nepisodes);
                                                        } else {
                                                          mp.playerd.play();
                                                          context
                                                              .read<
                                                                  MiniPlayerProvider>()
                                                              .closePlayer(
                                                                  nplayer: mp
                                                                      .playerd,
                                                                  playing: true,
                                                                  isshow: true);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                mp.playerd.hasNext
                                                    ? SizedBox(
                                                        width: 30,
                                                        child: Container(
                                                          child: IconButton(
                                                            splashColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            icon: Icon(
                                                              Icons
                                                                  .chevron_right,
                                                              color:
                                                                  Colors.white,
                                                              size: 30,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              if (mp.playerd
                                                                      .loopMode ==
                                                                  LoopMode
                                                                      .one) {
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            "Audio is in loop mode. Can not go to next.");
                                                              } else {
                                                                nextId();
                                                                mp.playerd
                                                                    .seekToNext();
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: 30,
                                                      ),
                                              ],
                                            ),
                                          ],
                                        )),
                                    InkWell(
                                      overlayColor: MaterialStatePropertyAll(
                                          Colors.transparent),
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        final SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setBool("timerEnabled", false);
                                        prefs.remove("current_id");

                                        player.pause();
                                        playerInfo(false, false);
                                      },
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(),
                                          child: Icon(Icons.close,
                                              color: Colors.white)),
                                    )
                                  ],
                                ),
                                StreamBuilder<PositionData>(
                                  stream: _positionDataStream,
                                  builder: (context, snapshot) {
                                    final positionData = snapshot.data;
                                    return SeekBarMini(
                                      player: mp.playerd,
                                      duration: positionData?.duration ??
                                          Duration.zero,
                                      position: positionData?.position ??
                                          Duration.zero,
                                      bufferedPosition:
                                          positionData?.bufferedPosition ??
                                              Duration.zero,
                                      onChangeEnd: (newPosition) {
                                        mp.playerd.seek(newPosition);
                                      },
                                    );
                                  },
                                ),
                              ]),
                            ));
                      }),
                )
              : SizedBox();
        }),
        itemLoaded
            ? BottomNavigationBar(
                iconSize: 30,
                enableFeedback: false,
                type: BottomNavigationBarType.fixed,
                items: itemsData,
                backgroundColor: Colors.black,
                currentIndex: _selectedIndex < 5 ? _selectedIndex : 0,
                showUnselectedLabels: true,
                unselectedItemColor: Colors.white.withOpacity(0.7),
                unselectedLabelStyle:
                    GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
                selectedLabelStyle:
                    GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
                selectedItemColor: Colors.white.withOpacity(0.7),
                onTap: _onItemTapped,
                elevation: 0,
              )
            : SizedBox()
      ],
    );
  }
}
