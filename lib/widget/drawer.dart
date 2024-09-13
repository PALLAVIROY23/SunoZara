import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/api/api_constant.dart';
import 'package:sunozara/api/storage.dart';
import 'package:sunozara/articles/list.dart';
import 'package:sunozara/audio/favorite.dart';
import 'package:sunozara/auth/login.dart';
import 'package:sunozara/brwoser.dart';
import 'package:sunozara/constants.dart';
import 'package:sunozara/dashboard_tab.dart';
import 'package:sunozara/product/orders.dart';
import 'package:sunozara/product/product_list.dart';
import 'package:sunozara/profile.dart';
import 'package:sunozara/subscription/info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../articles/cat_list.dart';
import '../articles/category_item.dart';
import '../audio/cat_list.dart';
import '../audio/category_item.dart';
import '../audio/my_downloads.dart';
import '../auth/authentication.dart';
import '../provider/miniplayer.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  String name = "";
  String email = "";
  String photo = "";
  String app_version = "";
  bool is_audio_enable = false;
  bool is_book_enable = false;
  bool is_article_enable = false;
  bool deleting = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProfile();
  }

  loadProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("user_name").toString();
      email = prefs.getString("user_email").toString();
      photo = prefs.getString("user_photo").toString();
      app_version = prefs.getString("app_version").toString();
      is_audio_enable = prefs.getBool("is_audio_enable")!;
      is_book_enable = prefs.getBool("is_book_enable")!;
      is_article_enable = prefs.getBool("is_article_enable")!;
    });
  }

  delNow() {
    ApiService().delAccount().then((value) {
      Fluttertoast.showToast(msg: "Your account has been deleted");
      logout1();
    }).onError((error, stackTrace) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Unable to delete your account. Kindly try again");
    });
  }

  delAcount() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        bool deleting = false;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter mystate) {
          return Container(
            height: 350.h,
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            color: HexColor("16181f"),
            child: Column(
              children: [
                SizedBox(
                  height: 10.h,
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
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  "Are you sure you want to delete account?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  "Once you delete your account, all your data will be removed from the server, and you will no longer be able to access it.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: [0.1, 1.0],
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
                              delNow();
                              mystate(() {
                                deleting = true;
                              });
                            },
                            child: deleting
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Yes! Delete",
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
  }

  logout() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            height: 350.h,
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            color: HexColor("16181f"),
            child: Column(
              children: [
                SizedBox(
                  height: 10.h,
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
                Image.asset(
                  "assets/logout.webp",
                  height: 100.h,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  "Are you sure you want to log out?",
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "You will be asked to log in again to listen your favorites.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
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
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                                padding: MaterialStatePropertyAll(
                                    EdgeInsets.symmetric(vertical: 10.w)),
                                foregroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.transparent)),
                            onPressed: () {
                              logout1();
                            },
                            child: Text(
                              "Log out",
                              style: GoogleFonts.poppins(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                          ))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
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
                                    EdgeInsets.symmetric(vertical: 10.w)),
                                foregroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.transparent)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  logout1() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic keys = prefs
        .getKeys()
        .where((String key) =>
            key != "tc" &&
            key != "RZP_KEY" &&
            key != "languages" &&
            key.contains("download_id_") == false &&
            key.contains("file_id_") == false &&
            key.contains("audio_info_") == false &&
            key.contains("downloadList_") == false)
        .toList();

    for (int i = 0; i < keys.length; i++) {
      prefs.remove(keys[i]);
    }
    player.stop();
    Authentication.signOut(context: context);
    Navigator.pop(context);
    context
        .read<MiniPlayerProvider>()
        .closePlayer(nplayer: player, playing: false, isshow: false);

    // prefs.remove("downloadList");
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight,
            alignment: Alignment.bottomCenter,
            child: LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white.withOpacity(
              0.6), //This will change the drawer background to blue.
          //other styles
        ),
        child: Drawer(
          child: Scaffold(
              bottomNavigationBar: SizedBox(
                // margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                height: 60.h,
                child: Container(
                  // decoration: BoxDecoration(color: Colors.black),
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: Column(
                    children: [
                      Text(
                        'Copyright @sunozara',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          height: 0.h,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'Version 1.1.9',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: SafeArea(
                  child: Container(
                padding: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        HexColor("#34343480"),
                        HexColor("#3D3D3D33"),
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: ListView(
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 10),
                      child: Row(children: [
                        CachedNetworkImage(
                          imageUrl:
                              ApiConstants.storagePATH + "/author/" + photo,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 70.0.w,
                            height: 70.0.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(
                            MdiIcons.accountCircle,
                            color: Colors.white,
                            size: 70,
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Container(
                          // decoration: BoxDecoration(color: Colors.red),
                          width: 170.w,
                          height: 80.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.split(" ")[0].toString().toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              InkWell(
                                  splashColor: Colors.transparent,
                                  overlayColor: MaterialStatePropertyAll(
                                      Colors.transparent),
                                  onTap: () {
                                    Navigator.pop(context);

                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.leftToRight,
                                            alignment: Alignment.bottomCenter,
                                            child: EditUserProfileScreen()));
                                  },
                                  child: Container(
                                    width: 125.w,
                                    height: 35.h,
                                    decoration: ShapeDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment(1.00, 0.00),
                                        end: Alignment(-2, 0),
                                        colors: [
                                          Color(0xFFE71F2E),
                                          Color(0xFF374AF9)
                                        ],
                                      ),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'View Profile',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                          height: 0.h,
                                        ),
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        )
                      ]),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    if (is_audio_enable) ...{
                      ListTile(
                        dense: true,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  alignment: Alignment.bottomCenter,
                                  child: DashboardTabScreen(1)),
                              (route) => false);
                        },
                        minLeadingWidth: 25,
                        leading: Image.asset(
                          "assets/ab.png",
                          height: 20.h,
                          width: 20.w,
                        ),
                        title: Text(
                          "Audio Books",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    },
                    if (is_article_enable) ...{
                      ListTile(
                        dense: true,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  alignment: Alignment.bottomCenter,
                                  child: DashboardTabScreen(2)),
                              (route) => false);
                        },
                        minLeadingWidth: 25,
                        leading: Image.asset(
                          "assets/art.png",
                          height: 20.h,
                          width: 20.w,
                        ),
                        title: Text(
                          "My Articles",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    },
                    if (is_audio_enable) ...{
                      ListTile(
                        dense: true,
                        minLeadingWidth: 25,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  alignment: Alignment.bottomCenter,
                                  child: DashboardTabScreen(4)),
                              (route) => false);
                        },
                        leading: Image.asset(
                          "assets/fav.png",
                          height: 20.h,
                          width: 20.w,
                        ),
                        title: Text(
                          "Favorites",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    },
                    if (is_audio_enable) ...{
                      ListTile(
                        dense: true,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                alignment: Alignment.bottomCenter,
                                child: MyDownloadListScreen()),
                          );
                        },
                        minLeadingWidth: 25,
                        leading: Image.asset(
                          "assets/pl.png",
                          height: 20.h,
                          width: 20.w,
                        ),
                        title: Text(
                          "Downloads",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    },
                    if (is_book_enable) ...{
                      ListTile(
                        dense: true,
                        onTap: () {
                          Navigator.pop(context);

                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  alignment: Alignment.bottomCenter,
                                  child: OrderScreen()));
                        },
                        minLeadingWidth: 25,
                        leading: Image.asset(
                          "assets/prd.png",
                          height: 20.h,
                          width: 20.w,
                        ),
                        title: Text(
                          "Orders",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    },
                    ListTile(
                      dense: true,
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                alignment: Alignment.bottomCenter,
                                child: SubscriptionInfoScreen(
                                  isPurchased: (bool l) {},
                                )));
                      },
                      minLeadingWidth: 25,
                      leading: Image.asset(
                        "assets/sub.png",
                        height: 20.h,
                        width: 20.w,
                      ),
                      title: Text(
                        "Subscriptions",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                alignment: Alignment.bottomCenter,
                                child: MyBrowser(
                                    "https://sunozara.com/page/terms-and-conditions")));
                      },
                      dense: true,
                      minLeadingWidth: 25,
                      leading: Image.asset(
                        "assets/link.png",
                        height: 20.h,
                        width: 20.w,
                      ),
                      title: Text(
                        "Terms & Conditions",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                alignment: Alignment.bottomCenter,
                                child: MyBrowser(
                                    "https://sunozara.com/page/privacy-and-policy")));
                      },
                      dense: true,
                      minLeadingWidth: 25,
                      leading: Image.asset(
                        "assets/link.png",
                        height: 20.h,
                        width: 20.w,
                      ),
                      title: Text(
                        "Privacy & Policy",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      minLeadingWidth: 25,
                      leading: Image.asset(
                        "assets/up.png",
                        height: 20.h,
                        width: 20.w,
                      ),
                      title: Text(
                        "Update App",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      onTap: () async {
                        logout();
                        // Authentication.signOut(context: context);
                        // Navigator.pop(context);
                        // final SharedPreferences prefs =
                        //     await SharedPreferences.getInstance();
                        // prefs.remove("user_token");
                        // Navigator.pushReplacement(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => LoginScreen()));
                      },
                      minLeadingWidth: 25,
                      leading: Image.asset(
                        "assets/logout.png",
                        height: 20.h,
                        width: 20.w,
                      ),
                      title: Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      onTap: () async {
                        delAcount();
                      },
                      minLeadingWidth: 25,
                      leading: Image.asset(
                        "assets/ruser.png",
                        height: 20.h,
                        width: 20.w,
                      ),
                      title: Text(
                        "Delete account",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                    )
                  ],
                ),
              ))),
        ));
  }
}
