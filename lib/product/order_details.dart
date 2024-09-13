import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rating_dialog/rating_dialog.dart';

import '../api/api.dart';
import 'orders.dart';

class OrderSummaryPage extends StatefulWidget {
  dynamic order;
  dynamic item;
  OrderSummaryPage({required this.order, required this.item, super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  int tabNo = -1;
  bool isLoaded = false;
  dynamic order;
  dynamic item;
  late BuildContext dialogContext;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadOrder();
  }

  void _showRatingAppDialog(String name) {
    final _ratingDialog = RatingDialog(
      title: Text(
        name.toString(),
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      message: Text(
        'Your feedback and rating play a crucial role in helping us enhance the quality of  delivery service.',
        style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      starColor: Colors.redAccent,
      image: Image.asset(
        "assets/logo.png",
        height: 40,
      ),
      starSize: 30,
      initialRating: 0,
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        ajaxLoader();
        ApiService()
            .rateOrder(item["id"].toString(), response.rating.toString(),
                response.comment.toString())
            .then((value) => successRate(value));
      },
      submitButtonText: 'Rate Now',
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ratingDialog,
    );
  }

  successRate(dynamic v) {
    Navigator.pop(dialogContext);
    Fluttertoast.showToast(msg: v["message"]);
    loadOrder();
  }

  errRate(er) {
    Navigator.pop(dialogContext);
    Fluttertoast.showToast(
        msg: "Something went wrong. Kindly contact to Admin");
  }

  ajaxLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.redAccent.withOpacity(0.1),
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SizedBox(
              height: 100,
              child: Center(
                // padding: EdgeInsets.all(15),
                child: Stack(children: [
                  Positioned(
                      top: 15,
                      right: 18,
                      child: Image.asset(
                        "assets/icon.png",
                        height: 50,
                      )),
                  LoadingAnimationWidget.discreteCircle(
                      color: Colors.redAccent,
                      size: 80,
                      secondRingColor: Colors.white,
                      thirdRingColor: Colors.white)
                ]),
              ),
            ));
      },
    );
  }

  loadOrder() {
    setState(() {
      isLoaded = true;
      order = widget.order;
      item = widget.item;
    });
    ApiService()
        .getOrder(widget.order['id'].toString(), widget.item['id'].toString())
        .then((value) => saveOrder(value))
        .onError((error, stackTrace) => failOrder());
  }

  saveOrder(dynamic value) {
    setState(() {
      isLoaded = true;
      order = value['orders'];
      item = value['item'];
    });
  }

  failOrder() {
    setState(() {
      isLoaded = true;
    });
    Fluttertoast.showToast(
        msg: "Unable to get Order details. Retry after few minutes",
        toastLength: Toast.LENGTH_SHORT);
  }

  failCancel(dynamic er) {
    //print(er);
    Fluttertoast.showToast(
        msg: "Unable to cancel order. Retry after few minutes",
        toastLength: Toast.LENGTH_SHORT);
  }

  cancelDone(dynamic value) {
    setState(() {
      item['status'] = 'cancelled';
    });
    Navigator.pop(dialogContext);
    if (value["success"]) {
      CoolAlert.show(
          context: context,
          confirmBtnColor: Colors.greenAccent.shade700,
          backgroundColor: Colors.white,
          type: CoolAlertType.success,
          animType: CoolAlertAnimType.rotate,
          width: 80,
          loopAnimation: true,
          title: "Your order item has been cancelled.",
          text: value["message"],
          barrierDismissible: false,
          confirmBtnText: "Close",
          onConfirmBtnTap: (() {
            Navigator.pop(context);

            // Navigator.pushReplacement(context,
            //      PageTransition(type: PageTransitionType.leftToRight,alignment: Alignment.bottomCenter, child: MyCoursesView()));
          })).then((value) => {});
    } else {
      CoolAlert.show(
          context: context,
          confirmBtnColor: Colors.redAccent,
          backgroundColor: Colors.white,
          type: CoolAlertType.error,
          animType: CoolAlertAnimType.rotate,
          width: 80,
          loopAnimation: true,
          title: "Unable to cancel your order.",
          text: value["message"],
          barrierDismissible: false,
          confirmBtnText: "Close",
          onConfirmBtnTap: (() {
            Navigator.pop(context);

            // Navigator.pushReplacement(context,
            //      PageTransition(type: PageTransitionType.leftToRight,alignment: Alignment.bottomCenter, child: MyCoursesView()));
          })).then((value) => {});
    }
  }

  cancelconfirm() {
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
                  "Do you want to cancel order?",
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Call us if you need any help from support.",
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
                                    EdgeInsets.symmetric(vertical: 10)),
                                foregroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                backgroundColor: MaterialStatePropertyAll(
                                    Colors.transparent)),
                            onPressed: () {
                              Navigator.pop(context);
                              cancelOrder();
                            },
                            child: Text(
                              "Yes Cancel",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w500),
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
    // CoolAlert.show(
    //     context: context,
    //     confirmBtnColor: Colors.redAccent,
    //     backgroundColor: Colors.white,
    //     showCancelBtn: true,
    //     type: CoolAlertType.warning,
    //     animType: CoolAlertAnimType.rotate,
    //     width: 80,
    //     loopAnimation: true,
    //     title: "Cancel Order.",
    //     text: "Do you want to cancel order?",
    //     barrierDismissible: false,
    //     confirmBtnText: "Yes",
    //     cancelBtnText: "No",
    //     onCancelBtnTap: () {
    //       // Navigator.pop(context);
    //     },
    //     onConfirmBtnTap: (() {
    //       Navigator.pop(context);
    //       cancelOrder();
    //       // Navigator.pushReplacement(context,
    //       //      PageTransition(type: PageTransitionType.leftToRight,alignment: Alignment.bottomCenter, child: MyCoursesView()));
    //     })).then((value) => {});
  }

  cancelOrder() {
    ajaxLoader();
    ApiService()
        .cancelOrder(item["id"].toString())
        .then((value) => {cancelDone(value)})
        .onError((error, stackTrace) => {failCancel(error)});
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 393;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return WillPopScope(
        // canPop: true,

        onWillPop: () {
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight,
                  alignment: Alignment.bottomCenter,
                  child: OrderScreen()));
          return Future<bool>.value(false);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 241, 240, 240),
              centerTitle: false,
              foregroundColor: Colors.black,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.0),
                child: Container(
                  color: Colors.black.withOpacity(0.051),
                  height: 1.0,
                ),
              ),
              title: Text(
                "Order Summary",
                style: GoogleFonts.poppins(),
              )),
          body: isLoaded
              ? ListView(children: [
                  order == null
                      ? Container(
                          child: Center(
                              child: Text("Unable to find order details")),
                        )
                      : Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10 * fem, vertical: 10 * fem),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["item"]["name"].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20 * ffem,
                                    fontWeight: FontWeight.w600,
                                    height: 1.5 * ffem / fem,
                                    color: Color(0xff000000),
                                  ),
                                ),
                                Text(
                                  "Order Date: ${DateFormat('dd-MMM-yyyy').format(DateTime.parse(item['created_at'].toString().split(' ')[0]))}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Color(0xff6c6c6c),
                                  ),
                                ),
                                if (item['status'].toString() ==
                                    'accepted') ...{
                                  Text(
                                    item['status'].toString().toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        color: Colors.blue, fontSize: 12),
                                  )
                                } else if (item['status'].toString() ==
                                    'refunded') ...{
                                  Text(
                                    item['status'].toString().toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        color: Colors.redAccent, fontSize: 12),
                                  )
                                } else if (item['status'].toString() ==
                                    'cancelled') ...{
                                  Text(
                                    item['status'].toString().toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        color: Colors.redAccent, fontSize: 12),
                                  )
                                } else if (item['status'].toString() ==
                                    'delivered') ...{
                                  Text(
                                    item['status'].toString().toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        color: Colors.green, fontSize: 12),
                                  )
                                } else ...{
                                  Text(
                                    item['status'].toString().toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        color: Colors.black, fontSize: 12),
                                  )
                                }
                              ]),
                        ),
                  Divider(),
                  if (item["status"].toString() == "delivered" &&
                      item["rating_given"] == 0) ...{
                    Container(
                      child: Center(
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.redAccent)),
                            onPressed: () {
                              _showRatingAppDialog(
                                  item["item"]["name"].toString());
                            },
                            child: Text(
                              "Rate Delivery",
                              style: GoogleFonts.poppins(color: Colors.white),
                            )),
                      ),
                    )
                  },
                  if (item["status"].toString() == "delivered" &&
                      item["rating_given"] == 1) ...{
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text(
                        "You have given your rating",
                        style: GoogleFonts.roboto(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Rating: " + item["rating_count"].toString()),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Remarks: ${item["rating_remarks"]}"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  },
                  Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            // rectangle605Rr (524:1271)
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 10 * fem, 0 * fem),
                            width: 3 * fem,
                            height: 27 * fem,
                            decoration: BoxDecoration(
                              color: Color(0xffd22127),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12 * fem),
                                bottomRight: Radius.circular(12 * fem),
                              ),
                            ),
                          ),
                          Container(
                              width: 365 * fem,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      child: Text("Item Total",
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500))),
                                  Text(
                                    '₹' + item["amount"].toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16 * ffem,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5 * ffem / fem,
                                      color: Color(0xff0049b7),
                                    ),
                                  )
                                ],
                              ))
                        ]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    // frame34966LqW (535:1029)
                    margin: EdgeInsets.fromLTRB(
                        10 * fem, 0 * fem, 10 * fem, 29 * fem),
                    // width: 353 * fem,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        item["discount"].toString() != "0"
                            ? Container(
                                // frame34954UKS (535:1042)
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 0 * fem, 7 * fem),
                                width: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      // couponfirst201aG (535:1043)
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 114 * fem, 0 * fem),
                                      child: Text(
                                        order["coupon_code"] != null
                                            ? 'Discount - (${order["coupon_code"] != null ? order["coupon_code"] : ''})'
                                            : 'Discount',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13 * ffem,
                                          fontWeight: FontWeight.w500,
                                          height: 1.5 * ffem / fem,
                                          color: Color(0xff0049b7),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      // yousaved80007tC (535:1044)
                                      'you saved ₹' +
                                          item["discount"].toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 13 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5 * ffem / fem,
                                        color: Color(0xff0049b7),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        Container(
                          // frame34951f92 (535:1039)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 7 * fem),
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                // taxesCek (535:1040)
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 0 * fem, 0 * fem),
                                child: Text(
                                  'GST (Inclusive)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Color(0xff4f4f4f),
                                  ),
                                ),
                              ),
                              Text(
                                // 8YQ (535:1041)
                                '₹' + item["gst"].toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 13 * ffem,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5 * ffem / fem,
                                  color: Color(0xff4f4f4f),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          // frame349525iY (535:1036)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 6 * fem),
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                // deliverychargeqBv (535:1037)
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 206 * fem, 0 * fem),
                                child: Text(
                                  'Delivery Charge',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Color(0xff4f4f4f),
                                  ),
                                ),
                              ),
                              Text(
                                // AEC (535:1038)
                                '₹0',
                                style: GoogleFonts.poppins(
                                  fontSize: 13 * ffem,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5 * ffem / fem,
                                  color: Color(0xff4f4f4f),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          // frame34965A7i (535:1030)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 17 * fem),
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                // grandtotalhtL (535:1031)
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 211 * fem, 0 * fem),
                                child: Text(
                                  'Grand Total',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Color(0xff303030),
                                  ),
                                ),
                              ),
                              Text(
                                // S5E (535:1032)
                                '₹' + item["payable"].toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 15 * ffem,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5 * ffem / fem,
                                  color: Color(0xff303030),
                                ),
                              ),
                            ],
                          ),
                        ),
                        order["discount"].toString() != "0"
                            ? Container(
                                // frame34956BoW (535:1048)
                                padding: EdgeInsets.fromLTRB(
                                    8 * fem, 9 * fem, 5 * fem, 8 * fem),
                                width: double.infinity,
                                height: 40 * fem,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0x4c000000)),
                                  color: Color(0x440049b7),
                                  borderRadius: BorderRadius.circular(7 * fem),
                                ),
                                child: Container(
                                  // frame34955K92 (535:1049)
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        // yourtotalsavingsUGp (535:1050)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 152 * fem, 0 * fem),
                                        child: Text(
                                          'Your total savings',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15 * ffem,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5 * ffem / fem,
                                            color: Color(0xff303030),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        // QRN (535:1051)
                                        '₹${order["discount"]}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15 * ffem,
                                          fontWeight: FontWeight.w500,
                                          height: 1.5 * ffem / fem,
                                          color: Color(0xff303030),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            // rectangle605Rr (524:1271)
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 10 * fem, 0 * fem),
                            width: 3 * fem,
                            height: 27 * fem,
                            decoration: BoxDecoration(
                              color: Color(0xffd22127),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12 * fem),
                                bottomRight: Radius.circular(12 * fem),
                              ),
                            ),
                          ),
                          Container(
                              child: Text("Order Details",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)))
                        ]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    // frame34972A9e (535:1052)
                    margin: EdgeInsets.fromLTRB(
                        10 * fem, 0 * fem, 10 * fem, 29 * fem),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // frame349709nG (535:1057)
                          width: 127 * fem,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // frame34968JfA (535:1058)
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 0 * fem, 20 * fem),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      // ordernumberT2G (535:1059)
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 0 * fem, 3 * fem),
                                      child: Text(
                                        'Order Number',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14 * ffem,
                                          fontWeight: FontWeight.w500,
                                          height: 1.5 * ffem / fem,
                                          color: Color(0xff6c6c6c),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      // mYk (535:1060)
                                      order["id"].toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                    Container(
                                      // ordernumberT2G (535:1059)
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 0 * fem, 3 * fem),
                                      child: Text(
                                        'Order Item ID',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14 * ffem,
                                          fontWeight: FontWeight.w500,
                                          height: 1.5 * ffem / fem,
                                          color: Color(0xff6c6c6c),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      // mYk (535:1060)
                                      item["id"].toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                // frame34969Joa (535:1061)
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      // payment4Gx (535:1062)
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 0 * fem, 3 * fem),
                                      child: Text(
                                        'Payment',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14 * ffem,
                                          fontWeight: FontWeight.w500,
                                          height: 1.5 * ffem / fem,
                                          color: Color(0xff6c6c6c),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      // cashondeliveryyui (535:1063)
                                      order["payment_method"]
                                          .toString()
                                          .toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  order["status"] == "delivered"
                      ? Container(
                          // frame34948Esa (535:1072)
                          margin: EdgeInsets.fromLTRB(
                              10 * fem, 0 * fem, 10 * fem, 0 * fem),
                          padding: EdgeInsets.fromLTRB(
                              15 * fem, 8 * fem, 15 * fem, 8 * fem),

                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(
                                      15 * fem, 8 * fem, 15 * fem, 8 * fem),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Color(0x4c000000)),
                                    color: Color(0xffffffff),
                                    borderRadius:
                                        BorderRadius.circular(7 * fem),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        // vector7Ag (535:1076)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            1.12 * fem, 5.88 * fem, 0 * fem),
                                        width: 15.12 * fem,
                                        height: 15.12 * fem,
                                        child: Image.asset(
                                          'assets/img/data/vector-T6p.png',
                                          width: 15.12 * fem,
                                          height: 15.12 * fem,
                                        ),
                                      ),
                                      Text(
                                        // downloadinvoicedep (535:1075)
                                        'Download Invoice',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13 * ffem,
                                          fontWeight: FontWeight.w500,
                                          height: 1.5 * ffem / fem,
                                          color: Color(0xff6c6c6c),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Text(""),
                                )
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),
                  item["status"] == "accepted"
                      ? Container(
                          // frame34948Esa (535:1072)
                          margin: EdgeInsets.fromLTRB(
                              10 * fem, 0 * fem, 10 * fem, 0 * fem),
                          padding: EdgeInsets.fromLTRB(
                              15 * fem, 8 * fem, 15 * fem, 8 * fem),

                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                    onTap: () {
                                      // cancelOrder();
                                      cancelconfirm();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(
                                          15 * fem, 8 * fem, 15 * fem, 8 * fem),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0x4c000000)),
                                        color: Color(0xffffffff),
                                        borderRadius:
                                            BorderRadius.circular(7 * fem),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            // vector7Ag (535:1076)
                                            // margin: EdgeInsets.fromLTRB(
                                            //     0 * fem, 1.12 * fem, 5.88 * fem, 0 * fem),
                                            // width: 15.12 * fem,
                                            // height: 15.12 * fem,
                                            child: Icon(
                                              MdiIcons.cancel,
                                              color: Colors.redAccent,
                                              size: 16,
                                            ),
                                          ),
                                          Text(
                                            // downloadinvoicedep (535:1075)
                                            ' Cancel Order',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13 * ffem,
                                              fontWeight: FontWeight.w500,
                                              height: 1.5 * ffem / fem,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                Container(
                                  child: Text(""),
                                )
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 30,
                  ),
                ])
              : Center(
                  child: Text("Please wait..."),
                ),
        ));
  }
}
