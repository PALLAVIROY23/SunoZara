import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/constants.dart';
import 'package:sunozara/product/thanku_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class CheckoutScreen extends StatefulWidget {
  List<CartModel> items;
  CheckoutScreen(this.items, {super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.redAccent, Colors.blue],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 80.0));
  late Razorpay _razorpay;
  String _character = "online";
  double total = 0.0;
  double delivery = 0.0;
  double discount = 0.0;
  double grand = 0.0;
  String address_id = "";
  String address = "";
  String rzp_id = "";
  bool addAdr = false;
  dynamic address_list = [];
  List<Map<String, String>> citems = [];
  TextEditingController _coupon = new TextEditingController();
  TextEditingController house_no = new TextEditingController();
  TextEditingController address_line_1 = new TextEditingController();
  TextEditingController address_line_2 = new TextEditingController();
  TextEditingController pincode = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  List<String> itemIds = [];
  bool saving = false;
  bool coupon_applied = false;
  bool coupon_success = false;
  String coupon_code = "";
  String oid = "";
  late BuildContext dialogContext;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    calcTotal();
    getAddress();
  }

  void _progress() {
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
                      top: 25,
                      right: 25,
                      child: Image.asset(
                        "assets/icon.png",
                        height: 30,
                      )),
                  LoadingAnimationWidget.discreteCircle(
                      color: Colors.redAccent,
                      size: 80,
                      secondRingColor: Colors.redAccent,
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
    ApiService().confirmOrder(oid, payid).then((value) => {pyCon(value)});
  }

  pyCon(value) {
    Navigator.pop(dialogContext);
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight,
            alignment: Alignment.bottomCenter,
            child: ThankYouPage(
              id: oid,
            )));
  }

  void _payNow(int amount, String rzp_id, String phone, String email,
      String name, String RZP_KEY) async {
    var options = {
      'key': RZP_KEY,
      'amount': amount,
      "currency": "INR",
      "order_id": rzp_id,
      "image": "https://sunozara.com/assets/images/sahitya-logo.png",
      'name': 'Sahitya Kriti',
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

  getAddress() {
    ApiService().getAddress().then((value) => {adData(value)});
  }

  getAddressd() {
    ApiService().getAddress().then((value) => {adDatad(value)});
  }

  addAddress() {
    setState(() {
      saving = true;
    });
    bool canContinue = true;
    String msg = "";
    if (phone.text.toString() == "" && phone.text.toString().length != 10) {
      canContinue = false;
      msg = "Kindly enter valid  Contact number";
    }
    if (pincode.text.toString() == "" && pincode.text.toString().length != 6) {
      canContinue = false;
      msg = "Kindly valid pincode";
    }
    if (address_line_1.text.toString() == "" &&
        address_line_1.text.toString().length <= 20) {
      canContinue = false;
      msg = "Kindly enter valid Address Line 1";
    }
    if (house_no.text.toString() == "") {
      canContinue = false;
      msg = "Kindly enter House/Flat No";
    }

    if (canContinue) {
      Navigator.pop(context);
      ApiService()
          .addAddress(
              house_no.text.toString(),
              address_line_1.text.toString(),
              address_line_2.text.toString(),
              pincode.text.toString(),
              phone.text.toString())
          .then((value) => {adxData(value)});
    } else {
      Fluttertoast.showToast(msg: msg);
    }
  }

  updateAddress(String aid) {
    setState(() {
      saving = true;
    });
    bool canContinue = true;
    String msg = "";
    if (phone.text.toString() == "" && phone.text.toString().length != 10) {
      canContinue = false;
      msg = "Kindly enter valid  Contact number";
    }
    if (pincode.text.toString() == "" && pincode.text.toString().length != 6) {
      canContinue = false;
      msg = "Kindly valid pincode";
    }
    if (address_line_1.text.toString() == "" &&
        address_line_1.text.toString().length <= 20) {
      canContinue = false;
      msg = "Kindly enter valid Address Line 1";
    }
    if (house_no.text.toString() == "") {
      canContinue = false;
      msg = "Kindly enter House/Flat No";
    }

    if (canContinue) {
      // Navigator.pop(context);
      _progress();
      ApiService()
          .updateAddress(
              aid,
              house_no.text.toString(),
              address_line_1.text.toString(),
              address_line_2.text.toString(),
              pincode.text.toString(),
              phone.text.toString())
          .then((value) => {adDatad(value)});
    } else {
      Fluttertoast.showToast(msg: msg);
    }
  }

  adxData(data) {
    setState(() {
      saving = false;
      addAdr = false;
      address_list = data["data"];
    });
    openAdddressModal();
    // setAdr(address_list[0]["address"].toString(),
    //     address_list[0]["id"].toString());
  }

  adDatad(data) {
    setState(() {
      saving = false;
      addAdr = false;
      address_list = data["data"];
    });
    Navigator.pop(context);
    Navigator.pop(dialogContext);
    openAdddressModal();
    // setAdr(address_list[0]["address"].toString(),
    //     address_list[0]["id"].toString());
  }

  adData(data) {
    setState(() {
      saving = false;
      addAdr = false;
      address_list = data["data"];
    });
  }

  calcTotal() {
    List<Map<String, String>> citemsx = [];
    double totalx = 0.0;
    List<String> itms = [];
    for (int i = 0; i < widget.items.length; i++) {
      totalx += widget.items[i].quantity * widget.items[i].variants[0].price;
      citemsx.add({
        "id": widget.items[i].productId.toString(),
        "qty": widget.items[i].quantity.toString(),
        "unitPrice": widget.items[i].variants[0].price.toString(),
      });
      itms.add(widget.items[i].productId.toString());
    }
    setState(() {
      total = totalx;
      citems = citemsx;
      grand = total + delivery - discount;
      itemIds = itms;
    });
  }

  applyCoupon() {
    if (_coupon.text.trim() != "") {
      _progress();
      ApiService()
          .applyCoupon(_coupon.text, (total + delivery).toString())
          .then((value) => {cSus(value)});
    } else {
      Fluttertoast.showToast(msg: "Kindly enter coupon code");
    }
  }

  cSus(value) {
    Navigator.pop(dialogContext);
    if (value["success"]) {
      //print(value);
      setState(() {
        coupon_applied = true;
        coupon_success = true;
        discount = double.parse(value["discount"].toString());
        coupon_code = value["coupon"].toString();
      });
      //print(discount);
      calcTotal();
    } else {
      setState(() {
        coupon_applied = true;
        coupon_success = false;
        discount = 0;
        coupon_code = "";
      });
      calcTotal();
    }
  }

  oer() {
    Navigator.pop(dialogContext);
    // Fluttertoast.showToast(msg: "Something went wrong");
  }

  proceedPayment() {
    if (address_id != "") {
      _progress();
      ApiService()
          .createOrder(itemIds, grand.toString(), discount.toString(),
              coupon_code, _character.toString(), address_id.toString())
          .then((value) => {cOrder(value)});
    } else {
      Fluttertoast.showToast(msg: "Kindly add delivery address");
    }
  }

  cOrder(value) async {
    Navigator.pop(dialogContext);
    if (value["success"]) {
      if (value["mode"] == "online") {
        setState(() {
          rzp_id = value['rzp_oid'].toString();
          oid = value["order_id"].toString();
        });
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        //
        String phone = prefs.getString("user_mobile").toString();
        String email = prefs.getString("user_email").toString();
        String name = prefs.getString("user_name").toString();
        _payNow(int.parse(value["amount"].toString()), rzp_id, phone, email,
            name, value["RZP_KEY"].toString());
      } else {
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.leftToRight,
                alignment: Alignment.bottomCenter,
                child: ThankYouPage(
                  id: value["order_id"].toString(),
                )));
        //move to success page
      }
    } else {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/player_bg.png"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: Container(
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
                      },
                      child: Text(
                        "Proceed",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ))
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text("Checkout",
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            automaticallyImplyLeading: true,
          ),
          body: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.only(left: 25),
                child: Text(
                  "Choose your payment method",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                  height: 35,
                  child: ListTile(
                    splashColor: Colors.transparent,
                    dense: true,
                    onTap: () {
                      setState(() {
                        _character = "online";
                      });
                    },
                    title: Text(
                      'Pay Online with Cards or UPI',
                      style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    leading: Radio<String>(
                      fillColor: MaterialStatePropertyAll(Colors.redAccent),
                      value: 'online',
                      groupValue: _character,
                      onChanged: (String? value) {
                        setState(() {
                          _character = value!;
                        });
                      },
                    ),
                  )),
              SizedBox(
                  height: 35,
                  child: ListTile(
                    splashColor: Colors.transparent,
                    dense: true,
                    onTap: () {
                      setState(() {
                        _character = "cod";
                      });
                    },
                    title: Text(
                      'Pay on Delivery',
                      style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    leading: Radio<String>(
                      fillColor: MaterialStatePropertyAll(Colors.redAccent),
                      value: "cod",
                      groupValue: _character,
                      onChanged: (String? value) {
                        setState(() {
                          _character = value!;
                        });
                      },
                    ),
                  )),
              SizedBox(
                height: 15,
              ),
              Container(
                margin: EdgeInsets.only(left: 25, top: 15, right: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery Address",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 14),
                      ),
                      address_id != ""
                          ? InkWell(
                              onTap: () {
                                openAdddressModal();
                              },
                              child: Text(
                                "CHANGE",
                                style: GoogleFonts.poppins(
                                    color: Colors.redAccent, fontSize: 14),
                              ),
                            )
                          : SizedBox()
                    ]),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: address_id != ""
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Icon(
                              MdiIcons.mapMarker,
                              color: Colors.white,
                              size: 40,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                address.toString(),
                                style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12),
                              ),
                            )
                          ])
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 70),
                        child: GlowButton(
                            splashColor: Colors.grey,
                            glowColor: Colors.grey,
                            color: Colors.redAccent,
                            child: Text(
                              "Select Delivery Address",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 12),
                            ),
                            onPressed: () {
                              openAdddressModal();
                            }),
                      ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                // width: MediaQuery.of(context).size.width * 0.95,
                child: Row(
                  children: [
                    Expanded(
                        child: textFiled(
                            hinttext: "Enter Coupon Code",
                            ttype: TextInputType.text,
                            inputFormatters: [UpperCaseTextFormatter()],
                            controller: _coupon)),
                    Container(
                        width: 100,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.0, 1.0],
                              colors: [
                                Colors.blue,
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
                            //print("Hello");
                            applyCoupon();
                          },
                          child: Text(
                            "Apply",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ))
                  ],
                ),
              ),
              if (coupon_applied) ...{
                if (coupon_success) ...{
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Coupon code applied successfully.",
                      style: GoogleFonts.poppins(color: Colors.greenAccent),
                    ),
                  )
                } else ...{
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Invalid or expired coupon.",
                      style: GoogleFonts.poppins(color: Colors.redAccent),
                    ),
                  )
                }
              },
              SizedBox(
                height: 15,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7), fontSize: 14),
                      ),
                      Text(
                        "₹${total}",
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7), fontSize: 14),
                      ),
                    ]),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery Charges",
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7), fontSize: 14),
                      ),
                      Text(
                        "₹${delivery}",
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7), fontSize: 14),
                      ),
                    ]),
              ),
              discount > 0
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Discount",
                              style: GoogleFonts.poppins(
                                  color: Colors.greenAccent, fontSize: 14),
                            ),
                            Text(
                              "₹${discount}",
                              style: GoogleFonts.poppins(
                                  color: Colors.greenAccent, fontSize: 14),
                            ),
                          ]),
                    )
                  : SizedBox(),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Grand Total",
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7), fontSize: 14),
                      ),
                      Text(
                        "₹${grand}",
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7), fontSize: 14),
                      ),
                    ]),
              )
            ],
          ),
        ));
  }

  Widget textFiled(
      {hinttext,
      TextInputType? ttype,
      TextEditingController? controller,
      VoidCallback? onTap,
      inputFormatters,
      validator,
      bool? readonly}) {
    return Container(
        decoration: BoxDecoration(
            // color: Colors.white, borderRadius: BorderRadius.circular(6)
            ),
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 0),
        padding: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
                height: 50,
                child: TextFormField(
                  controller: controller,
                  readOnly: readonly ?? false,
                  keyboardType: ttype,
                  onTap: onTap,
                  validator: validator,
                  inputFormatters: inputFormatters,
                  style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4)
                      .copyWith(color: Color(0xff020E12)),
                  decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      hintText: hinttext,
                      fillColor: const Color.fromARGB(220, 255, 255, 255),
                      contentPadding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                      // suffixIcon: Container(
                      //   margin: EdgeInsets.only(right: 10),
                      //   width: 140,
                      //   child: Center(
                      //       child: GradientText(
                      //     'Apply Coupon',
                      //     style: GoogleFonts.poppins(
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 18,
                      //     ),
                      //     colors: [Colors.redAccent, Colors.blue],
                      //   )),
                      // ),
                      prefixIconColor: Color.fromARGB(255, 203, 201, 201),
                      // hintText: hinttext,
                      hintStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0)
                          .copyWith(color: Color(0xff020E12).withOpacity(0.3)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.12), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.12), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      )),
                )),
          ],
        ));
  }

  Widget textFiledx(
      {hinttext,
      TextInputType? ttype,
      TextEditingController? controller,
      VoidCallback? onTap,
      inputFormatters,
      validator,
      bool? readonly}) {
    return Container(
        decoration: BoxDecoration(
            // color: Colors.white, borderRadius: BorderRadius.circular(6)
            ),
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 0),
        padding: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 3),
              child: Text(
                hinttext,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            SizedBox(
                height: 50,
                child: TextFormField(
                  controller: controller,
                  readOnly: readonly ?? false,
                  keyboardType: ttype,
                  onTap: onTap,
                  validator: validator,
                  inputFormatters: inputFormatters,
                  style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0)
                      .copyWith(color: Color(0xff020E12)),
                  decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      hintText: hinttext,
                      fillColor: const Color.fromARGB(220, 255, 255, 255),
                      contentPadding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                      prefixIconColor: Color.fromARGB(255, 203, 201, 201),
                      // hintText: hinttext,
                      hintStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 0)
                          .copyWith(color: Color(0xff020E12).withOpacity(0.3)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.12), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.12), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      )),
                )),
          ],
        ));
  }

  setAdr(String address, String aid) {
    setState(() {
      address = address;
      address_id = aid;
    });
  }

  deleteAddress(daid) {
    _progress();

    ApiService().delAddress(daid.toString()).then((value) {
      Fluttertoast.showToast(msg: "Address deleted successfully");
      getAddressd();
    }).onError((error, stackTrace) {
      Navigator.pop(dialogContext);
      Fluttertoast.showToast(msg: "Unable to delete address");
    });
  }

  editAddresModal(address) {
    print(address);
    setState(() {
      house_no.text = address["info"]["house_no"].toString();
      address_line_1.text = address["info"]["address_line_1"].toString();
      address_line_2.text = address["info"]["address_line_2"].toString();
      pincode.text = address["info"]["pincode"].toString();
      phone.text = address["info"]["phone"].toString();
    });
    showModalBottomSheet(
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
                decoration: BoxDecoration(color: THEME_BLACK),
                margin: EdgeInsets.only(top: 30),
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    title: Text(
                      "Update Address",
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: THEME_BLACK,
                    foregroundColor: Colors.white,
                  ),
                  body: ListView(children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0),
                      child: textFiledx(
                          hinttext: "House/Flat No*",
                          ttype: TextInputType.text,
                          controller: house_no),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0),
                      child: textFiledx(
                          hinttext: "Address Line 1*",
                          ttype: TextInputType.text,
                          controller: address_line_1),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0),
                      child: textFiledx(
                          hinttext: "Address Line 2",
                          ttype: TextInputType.text,
                          controller: address_line_2),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0),
                      child: textFiledx(
                          hinttext: "Pincode*",
                          ttype: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: pincode),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0),
                      child: textFiledx(
                          hinttext: "Contact Phone*",
                          ttype: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: phone),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("* Indicates required field."),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.redAccent),
                              padding: MaterialStatePropertyAll(
                                  EdgeInsets.symmetric(vertical: 12)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ))),
                          onPressed: () {
                            if (!saving) {
                              updateAddress(address["info"]["id"].toString());
                            }
                          },
                          child: !saving
                              ? Text("Update address",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600))
                              : Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )),
                    )
                  ]),
                ));
          });
        });
  }

  openAdddressModal() {
    setState(() {
      addAdr = false;
      saving = false;
    });
    showModalBottomSheet(
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
                decoration: BoxDecoration(color: THEME_BLACK),
                margin: EdgeInsets.only(top: 30),
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    title: Text(
                      "Select Address",
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: THEME_BLACK,
                    foregroundColor: Colors.white,
                  ),
                  body: !addAdr
                      ? GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          children: [
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    house_no.text = "";
                                    address_line_1.text = "";
                                    address_line_2.text = "";
                                    pincode.text = "";
                                    phone.text = "";
                                    addAdr = true;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Center(
                                    child: Text("+ Add New Address"),
                                  ),
                                )),
                            for (int i = 0; i < address_list.length; i++) ...{
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            deleteAddress(address_list[i]["id"]
                                                .toString());
                                          },
                                          child: Icon(MdiIcons.trashCan),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                            editAddresModal(address_list[i]);
                                          },
                                          child: Icon(MdiIcons.pencil),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            address = address_list[i]["address"]
                                                .toString();
                                            address_id = address_list[i]["id"]
                                                .toString();
                                          });
                                          setAdr(
                                              address_list[i]["address"]
                                                  .toString(),
                                              address_list[i]["id"].toString());
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: Center(
                                            child: Text(address_list[i]
                                                    ["address"]
                                                .toString()),
                                          ),
                                        ))
                                  ],
                                ),
                              )
                            },
                          ],
                        )
                      : ListView(children: [
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0),
                            child: textFiledx(
                                hinttext: "House/Flat No*",
                                ttype: TextInputType.text,
                                controller: house_no),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0),
                            child: textFiledx(
                                hinttext: "Address Line 1*",
                                ttype: TextInputType.text,
                                controller: address_line_1),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0),
                            child: textFiledx(
                                hinttext: "Address Line 2",
                                ttype: TextInputType.text,
                                controller: address_line_2),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0),
                            child: textFiledx(
                                hinttext: "Pincode*",
                                ttype: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: pincode),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0),
                            child: textFiledx(
                                hinttext: "Contact Phone*",
                                ttype: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: phone),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("* Indicates required field."),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Colors.redAccent),
                                    padding: MaterialStatePropertyAll(
                                        EdgeInsets.symmetric(vertical: 12)),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ))),
                                onPressed: () {
                                  if (!saving) {
                                    addAddress();
                                  }
                                },
                                child: !saving
                                    ? Text("Add address",
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600))
                                    : Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )),
                          )
                        ]),
                ));
          });
        });
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
