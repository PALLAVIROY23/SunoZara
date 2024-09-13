import 'dart:convert';
import 'dart:io';

import 'package:animated_icon/animated_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:path_provider/path_provider.dart';
import '../api/api_constant.dart';
import '../audio/player.dart';
import '../placeholders.dart';

class AudioCardHorizontalDownloadWidget extends StatefulWidget {
  dynamic audio;
  String type;
  Function canReload;
  AudioCardHorizontalDownloadWidget(this.audio, this.type,
      {required this.canReload, super.key});

  @override
  State<AudioCardHorizontalDownloadWidget> createState() =>
      _AudioCardHorizontalDownloadWidgetState();
}

class _AudioCardHorizontalDownloadWidgetState
    extends State<AudioCardHorizontalDownloadWidget> {
  bool deleting = false;
  void handleClick(String item) {
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
                Icon(
                  MdiIcons.trashCan,
                  size: 50,
                  color: Colors.redAccent,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Do you want to delete?",
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Your deleted item can not be retrieved.",
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
                                    delete1(item);
                                  }
                                },
                                child: Text(
                                  "Yes Delete",
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

    // ApiService().delAudioDownload(item).then((value) {
    //   confirm(value);
    // }).onError((error, stackTrace) {
    //   lep();
    // });
  }

  delete1(String item) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dl = prefs.getString("downloadingList");
    String uid = prefs.getString("user_id").toString();
    if (dl != null) {
      List<String> downloadingList = List<String>.from(jsonDecode(dl));
      for (int i = 0; i < widget.audio['episodes_items'].length; i++) {
        prefs.remove(
            "download_id_${widget.audio['episodes_items'][i].toString()}_${uid}");
        prefs.remove(
            "file_id_${widget.audio['episodes_items'][i].toString()}_${uid}");
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String savePath =
            "${appDocDir.path}/${widget.audio['episodes_items'][i].toString()}.mp3";
        File file = File(savePath);
        if (await file.exists()) {
          file.deleteSync();
        }

        setState(() {
          downloadingList.remove(widget.audio['episodes_items'][i].toString());
        });
      }
      prefs.setString("downloadingList", jsonEncode(downloadingList));
    }
    ApiService().delAudioDownload(item).then((value) {
      confirm(value);
    }).onError((error, stackTrace) {
      lep();
    });
  }

  confirm(value) {
    Navigator.pop(context);
    setState(() {
      deleting = false;
      widget.canReload(true, widget.audio["id"].toString());
    });
  }

  lep() {
    Fluttertoast.showToast(msg: "Unable to delete audio from downloads");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
      child: Row(children: [
        InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.leftToRight,
                      alignment: Alignment.bottomCenter,
                      child: AudioPlayerScreen(
                        widget.audio,
                        widget.type,
                      )));
            },
            child: Container(
              child: CachedNetworkImage(
                imageUrl: ApiConstants.storagePATH +
                    "/audios/" +
                    widget.audio["image"].toString(),
                imageBuilder: (context, imageProvider) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    enabled: true,
                    child: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: BannerPlaceholder(80, 80),
                    )),
                errorWidget: (context, url, error) => Icon(Icons.image),
              ),
            )),
        InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.leftToRight,
                      alignment: Alignment.bottomCenter,
                      child: AudioPlayerScreen(widget.audio, widget.type)));
            },
            child: Container(
                width: MediaQuery.of(context).size.width - 130,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          widget.audio["title"].toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 14),
                        )),
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Icon(
                          MdiIcons.starCircle,
                          color: Colors.green,
                          size: 18,
                        ),
                        Text(
                          "${widget.audio['ratings'].toString()} (${widget.audio['view_count'].toString()} listens) ${widget.audio['duration'].toString()} min",
                          style: GoogleFonts.poppins(
                              color: TEXT_WHITE_SHADE, fontSize: 12),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      widget.audio['short_description'].toString(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          color: TEXT_WHITE_SHADE, fontSize: 12),
                    )
                  ],
                ))),
        if (widget.audio['dl_status'] != null) ...{
          !widget.audio['dl_status']
              ? InkWell(
                  overlayColor: MaterialStatePropertyAll(Colors.transparent),
                  onTap: () {
                    handleClick(widget.audio["id"].toString());
                  },
                  child: Container(
                    child: Icon(MdiIcons.trashCan, color: Colors.redAccent),
                  ))
              : Container(
                  child: AnimateIcon(
                    key: UniqueKey(),
                    onTap: () {
                      // handleClick(widget.audio["id"].toString());
                    },
                    iconType: IconType.continueAnimation,
                    height: 25,
                    width: 25,
                    color: Colors.white,
                    animateIcon: AnimateIcons.downArrow,
                  ),
                )
        }
      ]),
    );
  }
}
