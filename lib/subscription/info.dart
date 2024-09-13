import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/api/api_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../dashboard.dart';
import '../dashboard_tab.dart';
import '../placeholders.dart';
import '../product/thanku_page.dart';

class SubscriptionInfoScreen extends StatefulWidget {
  Function isPurchased;
  SubscriptionInfoScreen({required this.isPurchased, super.key});

  @override
  State<SubscriptionInfoScreen> createState() => _SubscriptionInfoScreenState();
}

class _SubscriptionInfoScreenState extends State<SubscriptionInfoScreen> {
  dynamic products = [];
  bool loaded = false;
  String active = "";
  late Razorpay _razorpay;
  bool canBuy = false;
  String current = "";
  String pay_amount = "";
  String oid = "";
  String rzp_id = "";
  dynamic info;
  late BuildContext dialogContext;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    loadData();
  }

  void _progress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.blue.withOpacity(0.1),
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
                      top: 25,
                      right: 25,
                      child: Image.asset(
                        "assets/icon.png",
                        height: 30,
                      )),
                  LoadingAnimationWidget.discreteCircle(
                      color: Colors.teal,
                      size: 80,
                      secondRingColor: Colors.blue,
                      thirdRingColor: Colors.redAccent),
                ]),
              ),
            ));
      },
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _confirmPayment(
        oid, response.paymentId.toString(), response.signature.toString());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "Payment Failed", toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT);
  }

  _confirmPayment(String oid, String payid, String sig) async {
    _progress();
    ApiService().confirmSubs(oid, payid).then((value) => {pyCon(value)});
  }

  pyCon(value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("subscription", true);

    setState(() {
      widget.isPurchased(true);
      canBuy = false;
    });
    Navigator.pop(dialogContext);
    CoolAlert.show(
        context: context,
        confirmBtnColor: Colors.greenAccent.shade700,
        backgroundColor: Colors.white,
        type: CoolAlertType.success,
        animType: CoolAlertAnimType.rotate,
        width: 80,
        loopAnimation: true,
        title: "Thank you for choosing sunozara",
        text: value["message"],
        barrierDismissible: false,
        confirmBtnText: "Close",
        onConfirmBtnTap: (() {
          // loadData();
          goto();
        })).then((value) => {goto()});
    loadData();
  }

  goto() {
    Navigator.pop(context);
    // Navigator.pushReplacement(
    //     context,
    //     PageTransition(
    //         type: PageTransitionType.leftToRight,
    //         alignment: Alignment.bottomCenter,
    //         child: DashboardTabScreen(0)));
  }

  void _payNow(int amount, String rzp_id, String phone, String email,
      String name, String RZP_KEY) async {
    var options = {
      'key': RZP_KEY,
      'amount': amount,
      "currency": "INR",
      "order_id": rzp_id,
      "image": "https://sunozara.com/assets/images/sahitya-logo.png",
      'name': 'sunozara',
      'description': "Book Purchase",
      'retry': {'enabled': true, 'max_count': 4},
      'send_sms_hash': false,
      'prefill': {'contact': phone, 'email': email, 'name': name},
      "theme": {"color": "#e71f2e"}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Something went wrong", toastLength: Toast.LENGTH_LONG);
    }
  }

  proceedPayment() {
    _progress();
    ApiService().createSubs(active.toString()).then((value) => {cOrder(value)});
  }

  cOrder(value) async {
    Navigator.pop(dialogContext);
    if (value["success"]) {
      setState(() {
        rzp_id = value['rzp_oid'].toString();
        oid = value["order_id"].toString();
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      //
      String phone = prefs.getString("user_mobile").toString();
      String email = prefs.getString("user_email").toString();
      String name = prefs.getString("user_name").toString();
      _payNow(int.parse(value["amount"].toString()), rzp_id, phone, email, name,
          value["RZP_KEY"].toString());
    } else {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  loadData() {
    ApiService().subscriptions().then((value) => sData(value));
  }

  checkBuy() {
    if (current != active) {
      setState(() {
        canBuy = true;
      });
    } else {
      setState(() {
        canBuy = false;
      });
    }
  }

  sData(value) {
    for (int i = 0; i < value['subs'].length; i++) {
      if (value['subs'][i]['active']) {
        setState(() {
          current = value['subs'][i]['id'].toString();
          active = value['subs'][i]['id'].toString();
        });
      }
    }
    setState(() {
      loaded = true;
      products = value['subs'];
      info = value["info"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#171717"),
      appBar: AppBar(
        backgroundColor: HexColor("#171717"),
        foregroundColor: Colors.white,
        title: Text("Subscription"),
      ),
      bottomNavigationBar: canBuy
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.transparent)),
                        onPressed: () {
                          proceedPayment();
                          // setState(() {
                          //   widget.isPurchased(true);
                          // });
                        },
                        child: Text(
                          "Buy Subscription",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ))
                ],
              ),
            )
          : SizedBox(),
      body: ListView(
        children: [
          SizedBox(
            height: 20,
          ),
          if (loaded) ...{
            Center(
              child: Image.network(
                ApiConstants.storagePATH +
                    "/audios/" +
                    info["sub_img"].toString(),
                height: 140,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: Text(
                  info["subs_title"].toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: Text(
                  info["subs_sub_title"].toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: Text(
                  "Choose a Best Plan",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            if (products.length > 0) ...{
              for (int i = 0; i < products.length; i++) ...{
                InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        active = products[i]['id'].toString();
                        pay_amount = products[i]['offer_price'].toString();
                      });
                      checkBuy();
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.0, 1.0],
                              colors: [
                                if (active == products[i]["id"].toString()) ...{
                                  Colors.redAccent.shade400,
                                  Colors.blue,
                                } else ...{
                                  Color.fromARGB(255, 84, 83, 83),
                                  const Color.fromARGB(255, 43, 43, 43),
                                }
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/plan.png",
                                    height: 25,
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          products[i]["plan"].toString(),
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Price: ",
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              "₹" +
                                                  products[i]["amount"]
                                                      .toString(),
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  decorationThickness: 2,
                                                  decorationColor: Colors.black,
                                                  // decorationStyle:
                                                  //     TextDecorationStyle.wavy,
                                                  fontSize: 12),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "₹" +
                                                  products[i]["offer_price"]
                                                      .toString(),
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Validity: " +
                                                  products[i]["month"]
                                                      .toString() +
                                                  " Month(s)",
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            if (products[i]["active"]) ...{
                              Text(
                                "Your plan will expire on: " +
                                    products[i]["plan_expiry"].toString(),
                                style: GoogleFonts.poppins(color: Colors.amber),
                              ),
                              SizedBox(
                                height: 10,
                              )
                            }
                          ],
                        )))
              }
            } else ...{
              Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                    ),
                    Image.asset(
                      "assets/404.png",
                      width: 150,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Subscriptions not found",
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        ContentPlaceholder(
                          width: MediaQuery.of(context).size.width * 0.9,
                          lineType: ContentLineType.threeLines,
                        ),
                      ],
                    ),
                  )),
            }
          }
        ],
      ),
    );
  }
}
