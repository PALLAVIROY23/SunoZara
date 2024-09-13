import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunozara/api/api_constant.dart';

class AudioCardWidget extends StatefulWidget {
  dynamic audio;
  AudioCardWidget(this.audio, {super.key});

  @override
  State<AudioCardWidget> createState() => _AudioCardWidgetState();
}

class _AudioCardWidgetState extends State<AudioCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 117,
      margin: EdgeInsets.only(right: 10),
      child: Stack(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 117,
              height: 154,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(ApiConstants.storagePATH +
                      "/audios/" +
                      widget.audio["image"].toString()),
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              height: 45,
              child: Center(
                child: Text(
                  widget.audio["title"].toString(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
              ),
            )
          ],
        ),
        Positioned(
            top: 50,
            right: 40,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(50)),
              child: Center(
                child: Icon(
                  MdiIcons.play,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ))
      ]),
    );
  }
}
