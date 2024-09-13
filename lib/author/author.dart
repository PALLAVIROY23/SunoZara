import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/widget/audio_card_horizontal.dart';
import 'package:sunozara/widget/product_card_horizontal.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api_constant.dart';
import '../articles/card.dart';
import '../placeholders.dart';
import '../widget/bottom.dart';

class AuthorProfileScreen extends StatefulWidget {
  String id;
  AuthorProfileScreen(this.id, {super.key});

  @override
  State<AuthorProfileScreen> createState() => _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends State<AuthorProfileScreen> {
  dynamic audios = [];
  dynamic prodcuts = [];
  dynamic articles = [];
  dynamic user;
  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() {
    setState(() {
      loading = true;
    });
    ApiService()
        .getAuthorInfo(widget.id.toString())
        .then((value) => {aData(value)});
  }

  aData(data) {
    setState(() {
      audios = data["audios"];
      prodcuts = data["products"];
      articles = data["articles"];
      user = data["author"];
      loading = false;
    });
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.redAccent, Colors.blue],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 80.0));

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/player_bg.png"), fit: BoxFit.cover)),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              // title: Text("Author"),
              // automaticallyImplyLeading: false,
              // centerTitle: true,
            ),
            bottomNavigationBar: BottomWidget(0),
            body: Column(
              children: [
                if (loading) ...{
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
                } else ...{
                  // SizedBox(
                  //   height: 40,
                  // ),
                  // Row(
                  //   children: [
                  //     InkWell(
                  //       child: Icon(
                  //         MdiIcons.chevronLeft,
                  //         color: Colors.white,
                  //         size: 40,
                  //       ),
                  //     )
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        child: CachedNetworkImage(
                          imageUrl: ApiConstants.storagePATH +
                              "/author/" +
                              user["profile_photo"].toString(),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(color: Colors.white, width: 4),
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
                                child: BannerPlaceholder(110, 110),
                              )),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.image),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      user["name"].toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          // color: Colors.white,
                          fontSize: 18,
                          foreground: Paint()..shader = linearGradient,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: DefaultTabController(
                      length: 3,
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        appBar: AppBar(
                          centerTitle: false,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          title: TabBar(
                            isScrollable: true,
                            indicatorColor: Colors.redAccent,
                            labelColor: Colors.redAccent,
                            unselectedLabelColor: Colors.white,
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            tabs: [
                              Tab(
                                text: "Articles",
                              ),
                              Tab(
                                text: "Books",
                              ),
                              Tab(
                                text: "Audiobooks",
                              ),
                            ],
                          ),
                          automaticallyImplyLeading: false,
                        ),
                        body: TabBarView(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: articles.length > 0
                                  ? ListView(shrinkWrap: true, children: [
                                      for (int i = 0;
                                          i < articles.length;
                                          i++) ...{
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: ArticleCardWidget(
                                              articles[i], "author"),
                                        )
                                      }
                                    ])
                                  : Column(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                        ),
                                        Image.asset(
                                          "assets/404.png",
                                          width: 150,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "There is no Articles available for this author",
                                          style: GoogleFonts.poppins(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              fontWeight: FontWeight.w400),
                                        )
                                      ],
                                    ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: prodcuts.length > 0
                                  ? ListView(shrinkWrap: true, children: [
                                      for (int i = 0;
                                          i < prodcuts.length;
                                          i++) ...{
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: ProductCardHorizontalWidget(
                                                prodcuts[i]))
                                      }
                                    ])
                                  : Column(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                        ),
                                        Image.asset(
                                          "assets/404.png",
                                          width: 150,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "There is no Books available for this author",
                                          style: GoogleFonts.poppins(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              fontWeight: FontWeight.w400),
                                        )
                                      ],
                                    ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: audios.length > 0
                                  ? ListView(shrinkWrap: true, children: [
                                      for (int i = 0;
                                          i < audios.length;
                                          i++) ...{
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: AudioCardHorizontalWidget(
                                                audios[i], "back"))
                                      }
                                    ])
                                  : Column(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                        ),
                                        Image.asset(
                                          "assets/404.png",
                                          width: 150,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "There is no Audiobook available for this author",
                                          style: GoogleFonts.poppins(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              fontWeight: FontWeight.w400),
                                        )
                                      ],
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                }
              ],
            )));
  }
}
