import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/placeholders.dart';
import 'package:shimmer/shimmer.dart';

import 'api/api_constant.dart';
import 'articles/acard.dart';
import 'articles/card.dart';
import 'brwoser.dart';
import 'widget/ach.dart';
import 'widget/audio_card_horizontal.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalScreen extends StatefulWidget {
  dynamic city;
  LocalScreen(this.city, {super.key});

  @override
  State<LocalScreen> createState() => _LocalScreenState();
}

class _LocalScreenState extends State<LocalScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    tabController = TabController(
      initialIndex: selectedIndex,
      length: 3,
      vsync: this,
    );
    tabController.addListener(_handleTabSelection);
  }

  loadData() {
    print(widget.city['description']
        .toString()
        .replaceAll("../../", "https://sunozara.com/"));
  }

  _handleTabSelection() {
    setState(() {
      selectedIndex = tabController.index;
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      Fluttertoast.showToast(msg: "Unable to open");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            // color: Colors.black,
            image: DecorationImage(
                image: AssetImage("assets/player_bg.png"), fit: BoxFit.cover)),
        child: Scaffold(
            // bottomNavigationBar: BottomWidget(4),
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              automaticallyImplyLeading: true,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              // leading: BackButton(
              //   onPressed: () {
              //     //print("back Pressed");
              //     setState(() {
              //       widget.getIndex(0);
              //     });
              //   },
              // ),
              title: Text(
                widget.city['title'].toString(),
                style: GoogleFonts.poppins(),
              ),
            ),
            body: ListView(
              children: [
                widget.city['gallery'].length > 0
                    ? Container(
                        height: 140,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (int i = 0;
                                i < widget.city['gallery'].length;
                                i++) ...{
                              InkWell(
                                  onTap: () {
                                    _launchUrl(widget.city['gallery'][i]['url']
                                        .toString());
                                    // Navigator.push(
                                    //     context,
                                    //     PageTransition(
                                    //         type:
                                    //             PageTransitionType.leftToRight,
                                    //         alignment: Alignment.bottomCenter,
                                    //         child: MyBrowser(widget
                                    //             .city['gallery'][i]['url']
                                    //             .toString())));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    margin: EdgeInsets.only(right: 15),
                                    child: CachedNetworkImage(
                                      imageUrl: ApiConstants.storagePATH +
                                          "/" +
                                          widget.city['gallery'][i]['image']
                                              .toString(),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        height: 130,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              enabled: true,
                                              child: SingleChildScrollView(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                child:
                                                    BannerPlaceholder(130, 200),
                                              )),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.image),
                                    ),
                                  ))
                            }
                          ],
                        ),
                      )
                    : SizedBox(),
                DefaultTabController(
                  initialIndex: 0,
                  length: 3, // Number of tabs
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TabBar(
                          indicatorColor: Colors.redAccent,
                          labelColor: Colors.redAccent,
                          unselectedLabelColor: Colors.white,
                          dividerColor: Colors.transparent,
                          onTap: (int index) {
                            setState(() {
                              selectedIndex = index;
                              tabController.animateTo(index);
                            });
                          },
                          labelStyle: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          tabs: [
                            Tab(
                              text: "Description",
                            ),
                            Tab(
                              text: "Articles",
                            ),
                            Tab(
                              text: "Audiobooks",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedIndex == 0) ...{
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16)),
                    margin:
                        EdgeInsets.only(top: 10, bottom: 50, left: 5, right: 5),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: HtmlWidget(
                            widget.city['description'].toString().replaceAll(
                                "../../", "https://sunozara.com/"),
                            textStyle: GoogleFonts.roboto(color: Colors.white),
                            customStylesBuilder: (element) {
                          if (element.attributes.containsKey("href")) {
                            return {'color': 'red'};
                          }
                          return null;
                        }, onTapUrl: (url) {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  alignment: Alignment.bottomCenter,
                                  child: MyBrowser(url)));
                          return true;
                        })),
                  )
                },
                if (selectedIndex == 1) ...{
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 50),
                    child: widget.city['article'].length > 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 0;
                                  i < widget.city['article'].length;
                                  i++) ...{
                                Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: AArticleCardWidget(
                                        widget.city['article'][i], "llll"))
                              }
                            ],
                          )
                        : Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                ),
                                Image.asset(
                                  "assets/404.png",
                                  width: 150,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Articles not found",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                          ),
                  )
                },
                if (selectedIndex == 2) ...{
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 50),
                    child: widget.city['audio'].length > 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 0;
                                  i < widget.city['audio'].length;
                                  i++) ...{
                                AAudioCardHorizontalWidget(
                                  widget.city['audio'][i],
                                  "categoryccc",
                                )
                              }
                            ],
                          )
                        : Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                ),
                                Image.asset(
                                  "assets/404.png",
                                  width: 150,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Audiobook not found",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                          ),
                  )
                }
              ],
            )));
  }
}
