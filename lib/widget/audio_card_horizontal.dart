import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/constants.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api_constant.dart';
import '../audio/player.dart';
import '../placeholders.dart';

class AudioCardHorizontalWidget extends StatefulWidget {
  dynamic audio;
  String type;
  AudioCardHorizontalWidget(this.audio, this.type, {super.key});

  @override
  State<AudioCardHorizontalWidget> createState() =>
      _AudioCardHorizontalWidgetState();
}

class _AudioCardHorizontalWidgetState extends State<AudioCardHorizontalWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          // setState(() {
          //   widget.audio['view_count'] =
          //       int.parse(widget.audio['view_count'].toString()) + 1;
          // });
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight,
                  alignment: Alignment.bottomCenter,
                  child: AudioPlayerScreen(widget.audio, widget.type)));
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
          child: Row(children: [
            Container(
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
            ),
            Container(
                width: MediaQuery.of(context).size.width - 120,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.audio["title"].toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 14),
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
                ))
          ]),
        ));
  }
}
