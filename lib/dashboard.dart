import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/articles/cat_list.dart';
import 'package:sunozara/audio/player.dart';
import 'package:sunozara/constants.dart';
import 'package:sunozara/dashboard_tab.dart';
import 'package:sunozara/local.dart';
import 'package:sunozara/search.dart';
import 'package:sunozara/select_lang.dart';
import 'package:sunozara/widget/audio_card.dart';
import 'package:sunozara/widget/bottom.dart';
import 'package:sunozara/widget/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'api/api_constant.dart';
import 'articles/card.dart';
import 'articles/category_item.dart';
import 'audio/cat_list.dart';
import 'audio/category_item.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'placeholders.dart';
import 'product/product_details.dart';
import 'product/product_list.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:path_provider/path_provider.dart';

class DashboardScreen extends StatefulWidget {
  Function getIndex;
  Function getCat;
  DashboardScreen({required this.getIndex, required this.getCat, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  FToast? fToast;
  String uid = "";
  dynamic languages = [];
  dynamic sliders = [];
  dynamic audios = [];
  dynamic categories = [];
  dynamic products = [];
  dynamic articles = [];
  List<String> selectedLang = [];
  bool sliderLoaded = false;
  bool is_audio_enable = false;
  bool is_book_enable = false;
  bool is_article_enable = false;
  dynamic homeCustoms = [];
  dynamic cities = [];
  bool fakeloader = false;
  bool oupdated = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast?.init(context);
    fkl();
    setplatform();
    checkSubs();
    appData();
    loadData();
    loadLang();
    initPlatformState();
    loadDownloadFronServer();
    WidgetsBinding.instance.addObserver(this);
  }

  setplatform() {
    OneSignal.consentRequired(true);
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    OneSignal.initialize("de9db8ca-7f2c-4a7b-89fd-ffaab9a6c959");
    OneSignal.Notifications.requestPermission(true);
    OneSignal.consentGiven(true);

    // NOTE: Replace with your own app ID from https://www.onesignal.com

    // OneSignal.LiveActivities.setupDefault();
    // OneSignal.LiveActivities.setupDefault(options: new LiveActivitySetupOptions(enablePushToStart: false, enablePushToUpdate: true));

    // AndroidOnly stat only
    // OneSignal.Notifications.removeNotification(1);
    // OneSignal.Notifications.removeGroupedNotifications("group5");
    OneSignal.User.pushSubscription.optIn();

    // if (OneSignal.User.pushSubscription.id != null) {

    // }
    OneSignal.User.pushSubscription.addObserver((state) {
      // print(OneSignal.User.pushSubscription.token);
      // print(state.current.jsonRepresentation());
    });
    OneSignal.Notifications.clearAll();
    updateonesig(OneSignal.User.pushSubscription.id.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  updateonesig(String subs) {
    print(subs);
    print("onesignal-ppp");
    if (subs != "" && subs != 'null') {
      ApiService().updateOnesignal(subs).then((value) {
        s(value);
      });
    }
  }

  s(v) {
    print(v);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // App is in the background
      print('App is in the background');
    } else if (state == AppLifecycleState.resumed) {
      print('App is resumed from background');
    } else if (state == AppLifecycleState.inactive) {
      // App is inactive
      print('App is inactive');
    } else if (state == AppLifecycleState.detached) {
      player.stop();
      player.dispose();
      print('App is closed');
    }
  }

  fkl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList = jsonDecode(prefs.getString("home_audios").toString());
    if (sliderList == null) {
      setState(() {
        fakeloader = true;
      });
    }
  }

  checkSubs() {
    //print("Hello");
    ApiService().checkSubs().then((value) => sbs(value));
  }

  sbs(val) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("subscription", val["success"]);
  }

  void _onRefresh() async {
    appData();
    loadData();
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 2000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    appData();
    loadData();
    loadLang();
    await Future.delayed(Duration(milliseconds: 2000));
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  loadHomeData() {
    loadCachedArticles();
    loadCachedProducts();
    loadCachedAudio();
    loadCachedCat();
    loadCachedCity();
    loadCachedSlider();
    ApiService()
        .getHomeSettingData()
        .then((value) => {homeData(value)})
        .onError((error, stackTrace) => {
              Future.delayed(Duration(seconds: 2), () {
                loadHomeData();
              })
            });
  }

  loadLang() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList = jsonDecode(prefs.getString("languages").toString());

    if (sliderList != 'null') {
      setState(() {
        languages = sliderList;
      });
    }
  }

  homeData(data) {
    setState(() {
      homeCustoms = data["home"];
    });

    sliderData(data);
    cityData(data);
    catData(data);
    productData(data);
    artcileData(data);
    audioData(data);
  }

  appData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      is_audio_enable = prefs.getBool("is_audio_enable")!;
      is_book_enable = prefs.getBool("is_book_enable")!;
      is_article_enable = prefs.getBool("is_article_enable")!;
    });
  }

  loadData() {
    loadHomeData();

    // getSliders();
    // getLoc();
    // getCategories();

    getProducts();
    getArticles();

    getAudios();
    // startMiniPlayer();
  }

  getArticles() {
    loadCachedArticles();
    ApiService().getPopularArtciles().then((value) => {artcileData(value)});
  }

  loadCachedArticles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList =
        jsonDecode(prefs.getString("home_articles").toString());

    if (sliderList != 'null') {
      setState(() {
        articles = sliderList;
      });
    }
  }

  artcileData(data) async {
    print(data);
    dynamic sliderList = [];

    for (int i = 0; i < data['articles'].length; i++) {
      sliderList.add(data['articles'][i]);
    }
    setState(() {
      articles = sliderList;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("home_articles", jsonEncode(articles));
  }

  getProducts() {
    loadCachedProducts();
    ApiService().getPopularProducts().then((value) => {productData(value)});
  }

  loadCachedProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList =
        jsonDecode(prefs.getString("home_products").toString());

    if (sliderList != 'null') {
      setState(() {
        products = sliderList;
      });
    }
  }

  productData(data) async {
    dynamic sliderList = [];

    for (int i = 0; i < data['products'].length; i++) {
      sliderList.add(data['products'][i]);
    }
    setState(() {
      products = sliderList;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("home_products", jsonEncode(products));
  }

  getAudios() {
    loadCachedAudio();
    ApiService()
        .getPopularAudios()
        .then((value) => {audioData(value)})
        .onError((error, stackTrace) => ler());
  }

  ler() {
    // setState(() {
    //   fakeloader = false;
    // });
    Fluttertoast.showToast(
        msg: "Kindly check your innternet connection and reload");
  }

  loadCachedAudio() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList = jsonDecode(prefs.getString("home_audios").toString());

    if (sliderList != 'null') {
      setState(() {
        audios = sliderList;
      });
    }
  }

  audioData(data) async {
    dynamic sliderList = [];
    for (int i = 0; i < data['audios'].length; i++) {
      sliderList.add(data['audios'][i]);
    }
    setState(() {
      audios = sliderList;
      fakeloader = false;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("home_audios", jsonEncode(audios));
  }

  // getCategories() {
  //   loadCachedCat();
  //   ApiService().getPopulatCat().then((value) => {catData(value)});
  // }

  // getLoc() {
  //   loadCachedCity();
  //   ApiService().getcities().then((value) => {cityData(value)});
  // }

  cityData(data) async {
    dynamic sliderList = [];
    for (int i = 0; i < data['locations'].length; i++) {
      sliderList.add(data['locations'][i]);
    }
    setState(() {
      cities = sliderList;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("home_cities", jsonEncode(cities));
  }

  loadCachedCity() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList = jsonDecode(prefs.getString("home_cities").toString());

    if (sliderList != 'null') {
      setState(() {
        cities = sliderList;
      });
    }
  }

  loadCachedCat() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList = jsonDecode(prefs.getString("home_cats").toString());

    if (sliderList != 'null') {
      setState(() {
        categories = sliderList;
      });
    }
  }

  catData(data) async {
    dynamic sliderList = [];
    for (int i = 0; i < data['categories'].length; i++) {
      sliderList.add(data['categories'][i]);
    }
    setState(() {
      categories = sliderList;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("home_cats", jsonEncode(categories));
  }

  // getSliders() {
  //   loadCachedSlider();
  //   ApiService().getSliders().then((value) => {sliderData(value)});
  // }

  loadCachedSlider() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList = jsonDecode(prefs.getString("home_sliders").toString());

    if (sliderList != 'null') {
      setState(() {
        sliders = sliderList;
        sliderLoaded = true;
      });
    }
  }

  sliderData(data) async {
    dynamic sliderList = [];
    for (int i = 0; i < data['sliders'].length; i++) {
      sliderList.add(data['sliders'][i]);
    }
    setState(() {
      sliders = sliderList;
      sliderLoaded = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("home_sliders", jsonEncode(sliders));
  }

  loadDownloadFronServer() {
    ApiService().getAudioDownload().then((value) {
      dlList(value);
    }).onError((error, stackTrace) {
      lep();
    });
  }

  dlList(vl) async {
    dynamic data = vl["data"];
    dynamic dlList = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("user_id").toString();
    for (int i = 0; i < data.length; i++) {
      dlList.add(data[i]["id"].toString());
      prefs.setString("audio_info_${data[i]["id"]}", jsonEncode(data[i]));

      for (int j = 0; j < data[i]["episodes"].length; j++) {
        bool? al =
            prefs.getBool("download_id_${data[i]["episodes"][j]["id"]}_${uid}");

        // print("dlistx");
        // print(al);
        if (al == null || al == false) {
          String url = ApiConstants.storagePATH +
              "/episodes/" +
              data[i]["episodes"][j]["files"]["audio_file"].toString();

          // downloadFile(url, data[i]["episodes"][j]["id"].toString() + ".mp3",
          //     data[i]["episodes"][j]["id"].toString(), data[i]["id"]);
        }
      }
    }

    prefs.setString("downloadList_${uid}", jsonEncode(dlList));
  }

  lep() {}

  openLang() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return SelectLangScreen(
          updateLang: (bool rl) {
            if (rl) {
              Navigator.pop(context);
              loadData();
            }
          },
        );
      },
    );

    // Navigator.push(
    //     context,
    //     PageTransition(
    //         type: PageTransitionType.leftToRight,
    //         alignment: Alignment.bottomCenter,
    //         child: SelectLangScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
            backgroundColor: Colors.black,
            key: _key,
            // bottomNavigationBar: BottomWidget(0),
            drawer: DrawerWidget(),
            appBar: AppBar(
              foregroundColor: Colors.white.withOpacity(0.8),
              leading: Container(
                margin: EdgeInsets.only(right: 5),
                child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    size: 30,
                  ),
                  onPressed: () => _key.currentState!.openDrawer(),
                ),
              ),
              backgroundColor: THEME_BLACK,
              automaticallyImplyLeading: false,
              title: InkWell(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                      // color: const Color.fromARGB(45, 255, 255, 255),
                      borderRadius: BorderRadius.circular(60)),
                  child: TextFormField(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.leftToRight,
                              alignment: Alignment.bottomCenter,
                              child: SearchScreen()));
                    },
                    readOnly: true,
                    decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        hintText: "Search...",
                        fillColor: Color(0xFF161616),
                        contentPadding: EdgeInsets.fromLTRB(6, 0, 6, 0),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.4399999976158142),
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
                              color: Colors.black.withOpacity(0.12), width: 1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.12), width: 1),
                          borderRadius: BorderRadius.circular(60),
                        )),
                  ),
                ),
              ),
              actions: [
                InkWell(
                  onTap: () {
                    openLang();
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: 5,
                    ),
                    decoration: BoxDecoration(color: Colors.black),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.black,
                      backgroundImage: AssetImage("assets/lg.png"),
                    ),
                  ),
                )
              ],
            ),
            body: SmartRefresher(
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
                children: [
                  if (fakeloader) ...{
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
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                        height: 140.h,
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            if (sliders != null) ...{
                              for (int i = 0; i < sliders.length; i++) ...{
                                InkWell(
                                    onTap: () {
                                      if (sliders[i]['type'].toString() ==
                                          "audio") {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType
                                                    .leftToRight,
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: AudioPlayerScreen(
                                                    sliders[i]['audioData'],
                                                    "dashboard")));
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      margin: EdgeInsets.only(right: 15),
                                      child: CachedNetworkImage(
                                        imageUrl: ApiConstants.storagePATH +
                                            "/slider/" +
                                            sliders[i]['image'].toString(),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          height: 140.h,
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
                                                  child: BannerPlaceholder(
                                                      130, 200),
                                                )),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.image),
                                      ),
                                    ))
                              }
                            } else ...{
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
                                          height: 16.h,
                                        ),
                                        ContentPlaceholder(
                                          width: 200.w
                                          ,
                                          lineType: ContentLineType.threeLines,
                                        ),
                                      ],
                                    ),
                                  )),
                            }
                          ],
                        )),
                    if (cities != null) ...{
                      if (cities.length > 0) ...{
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Explore Local",
                                style: GoogleFonts.poppins(
                                  color: Color(0xFFBFBFBF),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          height: 124.h,
                          margin: EdgeInsets.symmetric(horizontal: 10.w),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (int i = 0; i < cities.length; i++) ...{
                                InkWell(
                                  highlightColor: Colors.transparent,
                                  overlayColor: MaterialStatePropertyAll(
                                      Colors.transparent),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.leftToRight,
                                            alignment: Alignment.bottomCenter,
                                            child: LocalScreen(cities[i])));
                                  },
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 100.h,
                                          width: 90.w,
                                          margin: EdgeInsets.only(right: 10.w),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          ApiConstants
                                                                  .storagePATH +
                                                              "/" +
                                                              cities[i]['image']
                                                                  .toString()))),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.w),
                                          child: Text(
                                            cities[i]['title'].toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.roboto(
                                                color: Colors.white
                                                    .withOpacity(0.7)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              }
                            ],
                          ),
                        ),
                      }
                    },
                    if (is_audio_enable) ...{
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Browse Audiobook By Category",
                              style: GoogleFonts.poppins(
                                color: Color(0xFFBFBFBF),
                                fontWeight: FontWeight.w500,
                                fontSize: 15.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                        height: 215.h,
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            if (categories != null) ...{
                              for (int i = 0;
                                  i < categories.length;
                                  i = i + 2) ...{
                                Container(
                                  margin: EdgeInsets.only(right: 5.w),
                                  child: Column(
                                    children: [
                                      if (i < categories.length) ...{
                                        InkWell(
                                            splashColor: Colors.transparent,
                                            overlayColor:
                                                MaterialStatePropertyAll(
                                                    Colors.transparent),
                                            onTap: () {
                                              // setState(() {
                                              //   widget.getIndex(
                                              //       1, categories[i]);
                                              //   widget.getCat(categories[i]);
                                              // });
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType
                                                          .leftToRight,
                                                      child: DashboardTabScreen(
                                                          1,
                                                          cat_id:
                                                              categories[i])));
                                            },
                                            child: Container(
                                              width: 80,
                                              height: 106,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10.h, bottom: 5.h),
                                                    height: 50.h,
                                                    width: 50.w,
                                                    child: CachedNetworkImage(
                                                      imageUrl: ApiConstants
                                                              .storagePATH +
                                                          "/category/" +
                                                          categories[i]["image"]
                                                              .toString(),
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        width: 50.0.w,
                                                        height: 50.0.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                      placeholder: (context,
                                                              url) =>
                                                          Shimmer.fromColors(
                                                              baseColor: Colors
                                                                  .grey
                                                                  .shade300,
                                                              highlightColor:
                                                                  Colors.grey
                                                                      .shade100,
                                                              enabled: true,
                                                              child:
                                                                  SingleChildScrollView(
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                child:
                                                                    BannerPlaceholder(
                                                                        50, 50),
                                                              )),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.image),
                                                    ),
                                                  ),
                                                  Text(
                                                    categories[i]["name"]
                                                        .toString(),
                                                    maxLines: 2,
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.clip,
                                                    style: GoogleFonts.poppins(
                                                        color: TEXT_WHITE_SHADE,
                                                        fontSize: 12.sp),
                                                  )
                                                ],
                                              ),
                                            )),
                                      },
                                      if (i + 1 < categories.length) ...{
                                        InkWell(
                                            splashColor: Colors.transparent,
                                            overlayColor:
                                                MaterialStatePropertyAll(
                                                    Colors.transparent),
                                            onTap: () {
                                              // setState(() {
                                              //   widget.getIndex(
                                              //       1, categories[i + 1]);
                                              //   widget
                                              //       .getCat(categories[i + 1]);
                                              // });
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType
                                                          .leftToRight,
                                                      child: DashboardTabScreen(
                                                          1,
                                                          cat_id: categories[
                                                              i + 1])));
                                            },
                                            child: Container(
                                              width: 80.w,
                                              height: 106.h,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10, bottom: 5),
                                                    height: 50.h,
                                                    width: 50.w,
                                                    child: CachedNetworkImage(
                                                      imageUrl: ApiConstants
                                                              .storagePATH +
                                                          "/category/" +
                                                          categories[i + 1]
                                                                  ["image"]
                                                              .toString(),
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        width: 50.0.w,
                                                        height: 50.0.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                      placeholder: (context,
                                                              url) =>
                                                          Shimmer.fromColors(
                                                              baseColor: Colors
                                                                  .grey
                                                                  .shade300,
                                                              highlightColor:
                                                                  Colors.grey
                                                                      .shade100,
                                                              enabled: true,
                                                              child:
                                                                  SingleChildScrollView(
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                child:
                                                                    BannerPlaceholder(
                                                                        50, 50),
                                                              )),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.image),
                                                    ),
                                                  ),
                                                  Text(
                                                    categories[i + 1]["name"]
                                                        .toString(),
                                                    maxLines: 2,
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.clip,
                                                    style: GoogleFonts.poppins(
                                                        color: TEXT_WHITE_SHADE,
                                                        fontSize: 12.sp),
                                                  )
                                                ],
                                              ),
                                            )),
                                      }
                                    ],
                                  ),
                                )
                              }
                            }
                          ],
                        ),
                      ),
                      if (audios != null) ...{
                        if (audios.length > 0) ...{
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Top Audiobooks",
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFFBFBFBF),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // setState(() {
                                    //   widget.getIndex(1, null);
                                    //   widget.getCat(null);
                                    // });

                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.leftToRight,
                                            child: DashboardTabScreen(1,
                                                cat_id: null)));
                                  },
                                  child: Text(
                                    "See all",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFFE71F2E),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            height: 205.h,
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                if (audios != null) ...{
                                  for (int i = 0; i < audios.length; i++) ...{
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType
                                                    .leftToRight,
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: AudioPlayerScreen(
                                                    audios[i], "dashboard")));
                                      },
                                      child: AudioCardWidget(audios[i]),
                                    )
                                  }
                                } else ...{
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
                                              height: 16.h,
                                            ),
                                            ContentPlaceholder(
                                              width: 117.w,
                                              lineType:
                                                  ContentLineType.threeLines,
                                            ),
                                          ],
                                        ),
                                      )),
                                }
                              ],
                            ),
                          ),
                        }
                      },
                    },
                    if (is_book_enable) ...{
                      if (products != null) ...{
                        if (products.length > 0) ...{
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Top Books",
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFFBFBFBF),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      widget.getIndex(3);
                                    });
                                    // Navigator.push(
                                    //     context,
                                    //     PageTransition(
                                    //         type:
                                    //             PageTransitionType.leftToRight,
                                    //         alignment: Alignment.bottomCenter,
                                    //         child: ProductListScreen()));
                                  },
                                  child: Text(
                                    "See all",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFFE71F2E),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            height: 205.h,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                if (products != null) ...{
                                  for (int i = 0; i < products.length; i++) ...{
                                    InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .leftToRight,
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: ProductDetailScreen(
                                                      products[i])));
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 117.w,
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: CachedNetworkImage(
                                                      imageUrl: ApiConstants
                                                              .storagePATH +
                                                          "/products/" +
                                                          products[i]["image"]
                                                              .toString(),
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        width: 117.w,
                                                        height: 154.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                      placeholder:
                                                          (context, url) =>
                                                              Image.asset(
                                                        'assets/page-1/images/sahitya-kriti-logo-1.png',
                                                        width: 117.w,
                                                        height: 154.h,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.image),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5.h,
                                                  ),
                                                  Container(
                                                    height: 45.h,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5.w),
                                                    child: Center(
                                                      child: Text(
                                                        products[i]["name"]
                                                            .toString(),
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Color(0xFF9F9F9F),
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
                                                      horizontal: 5.w,
                                                      vertical: 1.h),
                                                  decoration: BoxDecoration(
                                                      color: GR3,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(5),
                                                        bottomRight:
                                                            Radius.circular(5),
                                                      )),
                                                  child: Text(
                                                    products[i]["offer_price"]
                                                                .toString() !=
                                                            'null'
                                                        ? "₹" +
                                                            products[i][
                                                                    "offer_price"]
                                                                .toString()
                                                        : "₹" +
                                                            products[i]["price"]
                                                                .toString(),
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 10.sp),
                                                  ),
                                                )),
                                          ],
                                        ))
                                  }
                                } else ...{
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
                                              height: 16.h,
                                            ),
                                            ContentPlaceholder(
                                              width: 117.w,
                                              lineType:
                                                  ContentLineType.threeLines,
                                            ),
                                          ],
                                        ),
                                      )),
                                }
                              ],
                            ),
                          ),
                        }
                      },
                    },
                    if (articles != null) ...{
                      if (is_article_enable && articles.length > 0) ...{
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Top Articles",
                                style: GoogleFonts.poppins(
                                  color: Color(0xFFBFBFBF),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.sp,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.leftToRight,
                                          alignment: Alignment.bottomCenter,
                                          child:
                                              ArticleCategoryItemScreen(null)));
                                },
                                child: Text(
                                  "See all",
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFFE71F2E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        if (articles != null) ...{
                          for (int i = 0; i < articles.length; i++) ...{
                            Container(
                                margin: EdgeInsets.symmetric(horizontal: 10.w),
                                child:
                                    ArticleCardWidget(articles[i], "dashboard"))
                          }
                        } else ...{
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
                                      height: 16.h,
                                    ),
                                    ContentPlaceholder(
                                      width: 200.w,
                                      lineType: ContentLineType.threeLines,
                                    ),
                                  ],
                                ),
                              )),
                        },
                      },
                    },
                    SizedBox(
                      height: 10.h,
                    ),
                    if (homeCustoms != null) ...{
                      for (int i = 0; i < homeCustoms.length; i++) ...{
                        if ((homeCustoms[i]["type"].toString() == "audio" &&
                                is_audio_enable) ||
                            (homeCustoms[i]["type"].toString() == "article" &&
                                is_article_enable) ||
                            (homeCustoms[i]["type"].toString() == "book" &&
                                is_book_enable)) ...{
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  homeCustoms[i]["name"].toString(),
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFFBFBFBF),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.w,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                        },
                        if (homeCustoms[i]["type"].toString() == "audio" &&
                            is_audio_enable) ...{
                          Container(
                            height: 205.h,
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (int j = 0;
                                    j < homeCustoms[i]["data"].length;
                                    j++) ...{
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .leftToRight,
                                              alignment: Alignment.bottomCenter,
                                              child: AudioPlayerScreen(
                                                  homeCustoms[i]["data"][j],
                                                  "dashboard")));
                                    },
                                    child: AudioCardWidget(
                                        homeCustoms[i]["data"][j]),
                                  )
                                }
                              ],
                            ),
                          ),
                        },
                        SizedBox(
                          height: 10.h,
                        ),
                        if (homeCustoms[i]["type"].toString() == "article" &&
                            is_article_enable) ...{
                          for (int j = 0;
                              j < homeCustoms[i]["data"].length;
                              j++) ...{
                            Container(
                                margin: EdgeInsets.symmetric(horizontal: 10.w),
                                child: homeCustoms[i]["data"][j])
                          },
                        },
                        if (homeCustoms[i]["type"].toString() == "book" &&
                            is_book_enable) ...{
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            height: 205.h,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (int j = 0;
                                    j < homeCustoms[i]["data"].length;
                                    j++) ...{
                                  InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType
                                                    .leftToRight,
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: ProductDetailScreen(
                                                    homeCustoms[i]["data"]
                                                        [j])));
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 117.w,
                                            margin: EdgeInsets.only(right: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: CachedNetworkImage(
                                                    imageUrl: ApiConstants
                                                            .storagePATH +
                                                        "/products/" +
                                                        homeCustoms[i]["data"]
                                                                [j]["image"]
                                                            .toString(),
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      width: 117.w,
                                                      height: 154.h,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        image: DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/page-1/images/sahitya-kriti-logo-1.png',
                                                      width: 117.w,
                                                      height: 154.h,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.image),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5.h,
                                                ),
                                                Container(
                                                  height: 45.h,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5.w),
                                                  child: Center(
                                                    child: Text(
                                                      homeCustoms[i]["data"][j]
                                                              ["name"]
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.clip,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF9F9F9F),
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
                                                    horizontal: 5.w, vertical: 1.h),
                                                decoration: BoxDecoration(
                                                    color: GR3,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5),
                                                      bottomRight:
                                                          Radius.circular(5),
                                                    )),
                                                child: Text(
                                                  homeCustoms[i]["data"][j][
                                                                  "offer_price"]
                                                              .toString() !=
                                                          'null'
                                                      ? "₹" +
                                                          homeCustoms[i]["data"]
                                                                      [j][
                                                                  "offer_price"]
                                                              .toString()
                                                      : "₹" +
                                                          homeCustoms[i]["data"]
                                                                  [j]["price"]
                                                              .toString(),
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 10.sp),
                                                ),
                                              )),
                                        ],
                                      ))
                                }
                              ],
                            ),
                          ),
                        }
                      }
                    } else ...{
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
                                  height: 16.h,
                                ),
                                ContentPlaceholder(
                                  width: 117.w,
                                  lineType: ContentLineType.threeLines,
                                ),
                              ],
                            ),
                          )),
                    },
                    SizedBox(
                      height: 40.h,
                    )
                  }
                ],
              ),
            )));
  }
}
