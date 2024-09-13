import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/articles/details.dart';
import 'package:sunozara/constants.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api_constant.dart';
import '../placeholders.dart';

class AArticleCardWidget extends StatefulWidget {
  dynamic article;
  String source;
  String? keyd;
  AArticleCardWidget(this.article, this.source, {this.keyd = null, super.key});

  @override
  State<AArticleCardWidget> createState() => _AArticleCardWidgetState();
}

class _AArticleCardWidgetState extends State<AArticleCardWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          // setState(() {
          //   widget.article["view_count"] =
          //       int.parse(widget.article["view_count"].toString()) + 1;
          // });
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight,
                  alignment: Alignment.bottomCenter,
                  child: ArticleDetailScreen(
                    widget.article,
                    widget.source,
                    keyd: widget.keyd,
                  )));
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Row(children: [
            Container(
              child: CachedNetworkImage(
                imageUrl: ApiConstants.storagePATH +
                    "/image-manager/" +
                    widget.article["image"].toString(),
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
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.image),
              ),
            ),
            Container(
                width: MediaQuery.of(context).size.width - 115,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.article["category"]["name"].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.redAccent,
                              fontSize: 10),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.article["language"]["name"].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                              fontSize: 10),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Text(
                      widget.article["title"].toString(),
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                      style: GoogleFonts.poppins(
                          color: TEXT_WHITE_SHADE, fontSize: 12),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.green,
                          size: 18,
                        ),
                        Text(
                          " " + widget.article["user"]['name'].toString(),
                          style: GoogleFonts.poppins(
                              color: TEXT_WHITE_SHADE, fontSize: 14),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                    // RichText(
                    //   // bycontinueyouwillacceptourtcan (139:451)
                    //   text: TextSpan(
                    //     style: GoogleFonts.poppins(
                    //       fontWeight: FontWeight.w500,
                    //       color: Color(0xffffffff),
                    //     ),
                    //     children: [
                    //       TextSpan(
                    //         text: 'Author:',
                    //         style: GoogleFonts.poppins(
                    //             fontWeight: FontWeight.w500,
                    //             fontSize: 12,
                    //             color: Color(0xffe71f2e)),
                    //       ),
                    //       TextSpan(
                    //         text: widget.article["user"]["name"].toString(),
                    //         style: GoogleFonts.poppins(
                    //           fontWeight: FontWeight.w500,
                    //           fontSize: 12,
                    //           color: TEXT_WHITE_SHADE,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ))
          ]),
        ));
  }
}
