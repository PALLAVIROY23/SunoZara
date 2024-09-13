import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import '../api/api_constant.dart';
import '../dashboard.dart';
import '../dashboard_tab.dart';
import '../placeholders.dart';
import '../widget/bottom.dart';
import '../widget/drawer.dart';
import '../widget/product_card_horizontal.dart';
import 'cart.dart';

class ProductListScreen extends StatefulWidget {
  dynamic getIndex;
  ProductListScreen({required this.getIndex, super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  dynamic products = [];
  dynamic cats = [];
  bool loading = false;
  ScrollController _scrollController = ScrollController();
  int page = 1;
  bool canAppend = false;
  var cart = FlutterCart();
  int itemCount = 0;
  String current_id = "all";
  bool loaded = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    loadCart();
  }

  void _onRefresh() async {
    // monitor network fetch
    //print("Loading");
    loadData();
    loadCart();
    await Future.delayed(Duration(milliseconds: 2000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    //print("Loading");

    if (mounted) {
      loadData();
      loadCart();
    }
    await Future.delayed(Duration(milliseconds: 2000));
    _refreshController.loadComplete();
  }

  loadCart() {
    setState(() {
      loaded = false;
    });
    setState(() {
      itemCount = cart.cartItemsList.length;
    });
  }

  loadData() {
    loadCachedProducts();
    ApiService()
        .getProducts(page: page.toString(), catid: current_id)
        .then((value) => {pData(value)});
  }

  loadCachedProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList = jsonDecode(prefs.getString("products").toString());

    if (sliderList != 'null') {
      setState(() {
        products = sliderList;
      });
    }
  }

  pData(data) async {
    dynamic sliderList = [];
    if (canAppend) {
      for (int i = 0; i < products.length; i++) {
        sliderList.add(products[i]);
      }
    }
    // //print(data);
    for (int i = 0; i < data['data'].length; i++) {
      sliderList.add(data['data'][i]);
    }
    setState(() {
      loaded = true;
      cats = data["cats"];
      products = sliderList;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("products", jsonEncode(products));
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
              drawer: DrawerWidget(),
              appBar: AppBar(
                elevation: 0,
                // leading: BackButton(
                //   onPressed: () {
                //     //print("back Pressed");
                //     setState(() {
                //       widget.getIndex(0);
                //     });
                //   },
                // ),

                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                title: Text("Buy Books"),
                // automaticallyImplyLeading: false,
                // centerTitle: true,
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.leftToRight,
                              alignment: Alignment.bottomCenter,
                              child: CartScreen()));
                    },
                    child: badges.Badge(
                      position: badges.BadgePosition.topEnd(top: -10, end: -10),
                      showBadge: itemCount > 0 ? true : false,
                      ignorePointer: false,
                      onTap: () {},
                      badgeContent: Text(itemCount.toString()),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.circle,
                        badgeColor: Colors.white,
                        padding: EdgeInsets.all(5),
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.white, width: 2),
                        elevation: 0,
                      ),
                      child: Icon(Icons.shopping_cart),
                    ),
                  )
                ],
              ),
              // bottomNavigationBar: BottomWidget(3),
              body: NotificationListener<ScrollUpdateNotification>(
                child: SmartRefresher(
                    enablePullDown: true,
                    enableTwoLevel: false,
                    // enablePullUp: true,
                    header: WaterDropHeader(
                      waterDropColor: Colors.redAccent,
                    ),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        if (cats.length > 0) ...{
                          Container(
                            height: 30,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: [
                                InkWell(
                                    overlayColor: MaterialStatePropertyAll(
                                        Colors.transparent),
                                    onTap: () {
                                      setState(() {
                                        current_id = "all";
                                        loaded = false;
                                        canAppend = false;
                                        page = 1;
                                      });
                                      loadData();
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: current_id == 'all'
                                              ? Colors.redAccent
                                              : Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Text(
                                        "All",
                                        style: GoogleFonts.roboto(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    )),
                                for (int i = 0; i < cats.length; i++) ...{
                                  InkWell(
                                      overlayColor: MaterialStatePropertyAll(
                                          Colors.transparent),
                                      onTap: () {
                                        setState(() {
                                          current_id = cats[i]["id"].toString();
                                          loaded = false;
                                          canAppend = false;
                                          page = 1;
                                        });
                                        //print(current_id);
                                        loadData();
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: current_id ==
                                                    cats[i]["id"].toString()
                                                ? Colors.redAccent
                                                : Colors.white.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Text(
                                          cats[i]["name"].toString(),
                                          style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ))
                                }
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        },
                        if (loaded) ...{
                          if (products.length > 0) ...{
                            for (int i = 0; i < products.length; i++) ...{
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: ProductCardHorizontalWidget(products[i]),
                              )
                            },
                            if (loading) ...{
                              Container(
                                margin: EdgeInsets.only(bottom: 50),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              )
                            }
                          } else ...{
                            Container(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.25,
                                  ),
                                  Image.asset(
                                    "assets/404.png",
                                    width: 150,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Books not found",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.5),
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            )
                          }
                        } else ...{
                          for (int i = 0; i < 5; i++) ...{
                            Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                enabled: true,
                                child: SingleChildScrollView(
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      SizedBox(
                                        height: 16,
                                      ),
                                      ContentPlaceholder(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                20,
                                        lineType: ContentLineType.threeLines,
                                      ),
                                    ],
                                  ),
                                )),
                          }
                        }
                      ],
                    )),
                onNotification: (notification) {
                  //How many pixels scrolled from pervious frame
                  if (notification.metrics.atEdge) {
                    if (notification.metrics.pixels == 0) {
                      //print('At top');
                    } else {
                      setState(() {
                        page += 1;
                        loaded = true;
                        canAppend = true;
                        loadData();
                        //print(page);
                      });
                    }
                  }
                  return true;
                },
              ),
            )));
  }
}
