import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:shimmer/shimmer.dart';

import 'api/api_constant.dart';
import 'articles/card.dart';
import 'audio/player.dart';
import 'constants.dart';
import 'dashboard.dart';
import 'dashboard_tab.dart';
import 'placeholders.dart';
import 'product/product_details.dart';
import 'widget/audio_card.dart';

class SearchScreen extends StatefulWidget {
  String skey;
  SearchScreen({this.skey = "", super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FocusNode f1 = FocusNode();
  dynamic products = [];
  dynamic audios = [];
  dynamic articles = [];
  TextEditingController _key = new TextEditingController();
  bool searching = false;
  bool hasSearched = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadd();
  }

  loadd() {
    if (widget.skey.trim() == "") {
      focus();
    } else {
      setState(() {
        _key.text = widget.skey;
      });
      search();
    }
  }

  search() {
    if (_key.text.trim() != "") {
      setState(() {
        searching = true;
      });
      ApiService().search(_key.text.toString()).then((value) => {sData(value)});
    }
  }

  sData(data) {
    setState(() {
      searching = false;
      hasSearched = true;
      products = data["products"];
      audios = data["audios"];
      articles = data["articles"];
    });
  }

  focus() {
    // FocusScope.of(context).requestFocus(f1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/player_bg.png"), fit: BoxFit.cover)),
        child: WillPopScope(
            // canPop: true,

            onWillPop: () {
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType.leftToRight,
                      alignment: Alignment.bottomCenter,
                      child: DashboardTabScreen(0)));
              return Future<bool>.value(true);
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: true,
                  foregroundColor: Colors.white,
                  title: InkWell(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          // color: const Color.fromARGB(45, 255, 255, 255),
                          borderRadius: BorderRadius.circular(60)),
                      child: TextFormField(
                        controller: _key,
                        focusNode: f1,
                        readOnly: false,
                        autofocus: true,
                        onChanged: (String v) {
                          search();
                        },
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            hintText: "Search...",
                            fillColor: Colors.black.withOpacity(0.2),
                            contentPadding: EdgeInsets.fromLTRB(6, 0, 6, 0),
                            prefixIcon: Icon(
                              Icons.search,
                              color:
                                  Colors.white.withOpacity(0.4399999976158142),
                            ),
                            // suffixIcon: Icon(
                            //   MdiIcons.microphone,
                            //   color: Colors.white.withOpacity(0.4399999976158142),
                            // ),
                            prefixIconColor: Color.fromARGB(255, 203, 201, 201),
                            // hintText: hinttext,

                            hintStyle: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0)
                                .copyWith(
                                    color: Colors.white
                                        .withOpacity(0.4399999976158142)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.12),
                                  width: 1),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.12),
                                  width: 1),
                              borderRadius: BorderRadius.circular(60),
                            )),
                      ),
                    ),
                  )),
              body: ListView(
                children: [
                  searching
                      ? Center(
                          child: Container(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : SizedBox(),
                  if (audios.length == 0 &&
                      products.length == 0 &&
                      articles.length == 0) ...{
                    SizedBox(
                      height: 50,
                    ),
                    !hasSearched
                        ? SizedBox()
                        : Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: Text(
                                "We did not find anything. Please try searching with different keywords.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16),
                              ),
                            ),
                          )
                  },
                  if (audios.length > 0) ...{
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Found Audiobooks",
                            style: GoogleFonts.poppins(
                              color: Color(0xFFBFBFBF),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      height: 205,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (int i = 0; i < audios.length; i++) ...{
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.leftToRight,
                                      alignment: Alignment.bottomCenter,
                                      child: AudioPlayerScreen(
                                        audios[i],
                                        "search",
                                        skey: _key.text.toString(),
                                      ),
                                    ));
                              },
                              child: AudioCardWidget(audios[i]),
                            )
                          }
                        ],
                      ),
                    ),
                  },
                  if (products.length > 0) ...{
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Found Books",
                            style: GoogleFonts.poppins(
                              color: Color(0xFFBFBFBF),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 205,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (int i = 0; i < products.length; i++) ...{
                            InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.leftToRight,
                                          alignment: Alignment.bottomCenter,
                                          child: ProductDetailScreen(
                                              products[i])));
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 117,
                                      margin: EdgeInsets.only(right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  ApiConstants.storagePATH +
                                                      "/products/" +
                                                      products[i]["image"]
                                                          .toString(),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                width: 117,
                                                height: 154,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.image),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            height: 45,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Center(
                                              child: Text(
                                                products[i]["name"].toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF9F9F9F),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                              color: GR3,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(5),
                                                bottomRight: Radius.circular(5),
                                              )),
                                          child: Text(
                                            products[i]["offer_price"]
                                                        .toString() !=
                                                    'null'
                                                ? "₹" +
                                                    products[i]["offer_price"]
                                                        .toString()
                                                : "₹" +
                                                    products[i]["price"]
                                                        .toString(),
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        )),
                                  ],
                                ))
                          }
                        ],
                      ),
                    ),
                  },
                  if (articles.length > 0) ...{
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Found Articles",
                            style: GoogleFonts.poppins(
                              color: Color(0xFFBFBFBF),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    for (int i = 0; i < articles.length; i++) ...{
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: ArticleCardWidget(
                          articles[i],
                          "search",
                          keyd: _key.text,
                        ),
                      )
                    }
                  }
                ],
              ),
            )));
  }
}
