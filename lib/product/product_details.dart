import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:badges/badges.dart' as badges;
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/product/cart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_cart/flutter_cart.dart';

import '../api/api_constant.dart';
import '../author/author.dart';
import '../placeholders.dart';
import '../widget/product_card_light.dart';
import 'checkout.dart';

class ProductDetailScreen extends StatefulWidget {
  dynamic product;
  ProductDetailScreen(this.product, {super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  var cart = FlutterCart();
  dynamic rproducts = [];
  int itemCount = 0;
  bool loaded = false;
  discount(String price, String offer_price) {
    double p =
        (int.parse(price) - int.parse(offer_price)) * 100 / int.parse(price);
    return p.round().toString();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCart();
    loadRel();
  }

  loadRel() {
    ApiService()
        .getRelProducts(widget.product["id"].toString())
        .then((value) => {rData(value)})
        .onError((error, stackTrace) => led());
  }

  led() {
    setState(() {
      loaded = true;
    });
  }

  rData(data) {
    setState(() {
      rproducts = data["data"];
      loaded = true;
    });
  }

  loadCart() {
    setState(() {
      itemCount = cart.cartItemsList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        child: Row(children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.redAccent),
                    padding: MaterialStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ))),
                onPressed: () {
                  dynamic price =
                      widget.product["offer_price"] ?? widget.product["price"];
                  cart.addToCart(
                      cartModel: CartModel(
                          productId: widget.product["id"].toString(),
                          productName: widget.product["name"].toString(),
                          variants: [
                            ProductVariant(price: double.parse(price))
                          ],
                          quantity: 1,
                          productDetails: widget.product["name"].toString(),
                          productImages: [widget.product["image"].toString()],
                          productMeta: {"product": widget.product}));

                  setState(() {
                    itemCount = cart.cartItemsList.length;
                  });
                  Fluttertoast.showToast(msg: "Item added into cart");
                },
                child: Text("Add to cart",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ))),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: ElevatedButton(
                style: ButtonStyle(
                    // backgroundColor: MaterialStatePropertyAll(Colors.white),
                    backgroundColor: MaterialStatePropertyAll(Colors.blue),
                    padding: MaterialStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ))),
                onPressed: () {
                  List<CartModel> checkoutItems = [];
                  // checkoutItems.add(CartItem(
                  //   uuid: Random().nextInt(100) + 5000,
                  //   productId: widget.product["id"].toString(),
                  //   productName: widget.product["name"].toString(),
                  //   unitPrice: widget.product["offer_price"] != null
                  //       ? double.parse(widget.product["offer_price"].toString())
                  //       : double.parse(widget.product["price"].toString()),
                  //   subTotal: widget.product["offer_price"] != null
                  //       ? double.parse(widget.product["offer_price"].toString())
                  //       : double.parse(widget.product["price"].toString()),
                  //   quantity: 1,
                  //   productDetails: widget.product,
                  // ));
                  checkoutItems.add(CartModel(
                      productId: widget.product["id"].toString(),
                      quantity: 1,
                      productName: widget.product["name"].toString(),
                      variants: [
                        ProductVariant(
                            price: widget.product["offer_price"] != null
                                ? double.parse(
                                    widget.product["offer_price"].toString())
                                : double.parse(
                                    widget.product["price"].toString()))
                      ],
                      productDetails: widget.product["name"].toString(),
                      productImages: [widget.product["image"].toString()],
                      productMeta: {"product": widget.product}));

                  // cart.addToCart(
                  //     cartModel: CartModel(
                  //         productId: widget.product["id"].toString(),
                  //         productName: widget.product["name"].toString(),
                  //         variants: [
                  //           ProductVariant(price: double.parse(price))
                  //         ],
                  //         productDetails: widget.product["name"].toString(),
                  //         productImages: [widget.product["image"].toString()],
                  //         productMeta: {"product": widget.product}));
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.leftToRight,
                          alignment: Alignment.bottomCenter,
                          child: CheckoutScreen(checkoutItems)));
                },
                child: Text("Buy now",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                    ))),
          ),
        ]),
      ),
      appBar: AppBar(
        // backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: true,
        title: Text(
          "Book Details",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
        ),
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
      body: ListView(children: [
        if (!loaded) ...{
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
        } else ...{
          Container(
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1)),
            padding: EdgeInsets.symmetric(vertical: 10),
            height: MediaQuery.of(context).size.height * 0.4,
            child: CachedNetworkImage(
              imageUrl: ApiConstants.storagePATH +
                  "/products/" +
                  widget.product["image"].toString(),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      enabled: true,
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: BannerPlaceholder(110, 110),
                      )),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Text(
              widget.product["name"].toString(),
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          // Container(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: 15,
          //     vertical: 0,
          //   ),
          //   child: Row(children: [
          //     Container(
          //       margin: EdgeInsets.symmetric(horizontal: 0),
          //       child: RatingBar.builder(
          //         initialRating:
          //             double.parse(widget.product["ratings"].toString()),
          //         minRating: double.parse(widget.product["ratings"].toString()),
          //         direction: Axis.horizontal,
          //         allowHalfRating: true,
          //         itemSize: 12,
          //         unratedColor: Colors.grey,
          //         glow: false,
          //         ignoreGestures: true,
          //         maxRating: double.parse(widget.product["ratings"].toString()),
          //         itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
          //         itemBuilder: (context, _) => Icon(
          //           MdiIcons.star,
          //           size: 12,
          //           color: Colors.redAccent,
          //         ),
          //         onRatingUpdate: (rating) {
          //           //print(rating);
          //         },
          //       ),
          //     ),
          //     SizedBox(
          //       width: 10,
          //     ),
          //     Container(
          //       child: Text(
          //         "250 Ratings",
          //         style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue),
          //       ),
          //     )
          //   ]),
          // ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Row(
              children: [
                if (widget.product["offer_price"] != null) ...{
                  Container(
                    child: Text(
                      discount(widget.product["price"].toString(),
                              widget.product["offer_price"].toString()) +
                          "% Off ",
                      style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: Text(
                      " ₹${widget.product["price"]} ",
                      style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    child: Text(
                      " ₹" + widget.product["offer_price"].toString(),
                      style: GoogleFonts.poppins(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                } else ...{
                  Container(
                    child: Text(
                      " ₹" + widget.product["price"].toString(),
                      style: GoogleFonts.poppins(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                }
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 0,
            ),
            child: Row(children: [
              Text(
                "Category: ",
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                widget.product["category"]["name"].toString(),
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w400),
              )
            ]),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 0,
            ),
            child: Row(
              children: [
                Text(
                  "Language: ",
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.product["language"]["name"].toString(),
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight,
                        alignment: Alignment.bottomCenter,
                        child: AuthorProfileScreen(
                            widget.product["author"]["id"].toString())));
              },
              child: Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(
                          5.0,
                          5.0,
                        ),
                        blurRadius: 5.0,
                        spreadRadius: 2.0,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4)),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: ApiConstants.storagePATH +
                          "/author/" +
                          widget.product["author"]["image"].toString(),
                      imageBuilder: (context, imageProvider) => Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
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
                            child: BannerPlaceholder(50, 50),
                          )),
                      errorWidget: (context, url, error) => Icon(Icons.image),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Author",
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.product["author"]["name"].toString(),
                          style: GoogleFonts.poppins(),
                        )
                      ],
                    ),
                  )
                ]),
              )),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Text(
              "About Book",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 0,
            ),
            child: Html(
                shrinkWrap: true,
                data: widget.product["description"].toString()),
          ),
          if (rproducts.length > 0) ...{
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: Text(
                "You might also like",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            for (int i = 0; i < rproducts.length; i++) ...{
              ProductCardHorizontalLightWidget(rproducts[i]),
            }
          }
        }
      ]),
    );
  }
}
