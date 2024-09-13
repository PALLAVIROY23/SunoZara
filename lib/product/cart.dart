import 'package:flutter/material.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api_constant.dart';
import 'package:sunozara/constants.dart';

import 'checkout.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var cart = FlutterCart();
  List<CartModel> items = [];
  List<CartModel> checkoutItems = [];
  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.redAccent, Colors.blue],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 80.0, 20.0));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCartItem();
  }

  loadCartItem() {
    setState(() {
      items = cart.cartItemsList;
    });
  }

  addItem(CartModel item) {
    cart.updateQuantity(item.productId, item.variants, item.quantity + 1);

    loadCartItem();
  }

  minusItem(CartModel item) {
    cart.updateQuantity(item.productId, item.variants, item.quantity - 1);
    loadCartItem();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Cart Total",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "₹${cart.total}",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
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
                        setState(() {
                          checkoutItems = items;
                        });
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                alignment: Alignment.bottomCenter,
                                child: CheckoutScreen(checkoutItems)));
                      },
                      child: Text(
                        "Checkout",
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
            title: Text("Your Cart",
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            automaticallyImplyLeading: true,
            centerTitle: false,
          ),
          body: ListView(
            children: [
              for (int i = 0; i < items.length; i++) ...{
                Container(
                  child: Row(children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          image: DecorationImage(
                              image: NetworkImage(ApiConstants.storagePATH +
                                  "/products/" +
                                  items[i].productImages![0].toString()))),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 158,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].productName.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            items[i]
                                .productMeta!["product"]["author"]["name"]
                                .toString(),
                            style: GoogleFonts.poppins(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "₹${items[i].variants[0].price}/-",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 77,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        minusItem(items[i]);
                                      },
                                      child: Container(
                                        child: Text(
                                          "-",
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            foreground: Paint()
                                              ..shader = linearGradient,
                                          ),
                                        ),
                                      )),
                                  Container(
                                      child: Text("${items[i].quantity}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            foreground: Paint()
                                              ..shader = linearGradient,
                                          ))),
                                  InkWell(
                                      onTap: () {
                                        addItem(items[i]);
                                      },
                                      child: Container(
                                          child: Text("+",
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                foreground: Paint()
                                                  ..shader = linearGradient,
                                              )))),
                                ]),
                          ),
                          Container(
                            child: Text(
                              "₹${items[i].quantity * items[i].variants[0].price}",
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    )
                  ]),
                ),
                Divider(
                  color: Colors.white.withOpacity(0.2),
                )
              }
            ],
          ),
        ));
  }
}
