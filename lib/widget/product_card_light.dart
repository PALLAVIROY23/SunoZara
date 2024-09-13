import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/constants.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api_constant.dart';
import '../audio/player.dart';
import '../placeholders.dart';
import '../product/product_details.dart';

class ProductCardHorizontalLightWidget extends StatefulWidget {
  dynamic product;
  ProductCardHorizontalLightWidget(this.product, {super.key});

  @override
  State<ProductCardHorizontalLightWidget> createState() =>
      _ProductCardHorizontalLightWidgetState();
}

class _ProductCardHorizontalLightWidgetState
    extends State<ProductCardHorizontalLightWidget> {
  discount(String price, String offer_price) {
    double p =
        (int.parse(price) - int.parse(offer_price)) * 100 / int.parse(price);
    return p.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight,
                  alignment: Alignment.bottomCenter,
                  child: ProductDetailScreen(widget.product)));
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Row(children: [
            Container(
              margin: EdgeInsets.only(left: 10),
              child: CachedNetworkImage(
                imageUrl: ApiConstants.storagePATH +
                    "/products/" +
                    widget.product["image"].toString(),
                imageBuilder: (context, imageProvider) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
                      child: BannerPlaceholder(80, 80),
                    )),
                errorWidget: (context, url, error) => Icon(Icons.image),
              ),
            ),
            Container(
                width: MediaQuery.of(context).size.width - 120,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.product["category"]["name"].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.redAccent,
                              fontSize: 10),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.product["language"]["name"].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                              fontSize: 10),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Text(
                      widget.product["name"].toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          // color: Colors.white,
                          fontSize: 14),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    // Container(
                    //   margin: EdgeInsets.symmetric(horizontal: 0),
                    //   child: RatingBar.builder(
                    //     initialRating:
                    //         double.parse(widget.product["ratings"].toString()),
                    //     minRating:
                    //         double.parse(widget.product["ratings"].toString()),
                    //     direction: Axis.horizontal,
                    //     allowHalfRating: true,
                    //     itemSize: 10,
                    //     unratedColor: Colors.grey,
                    //     // itemCount: 5,
                    //     // glow: true,
                    //     // glowColor: Colors.amber,
                    //     glow: false,
                    //     ignoreGestures: true,
                    //     glowRadius: 5,
                    //     maxRating:
                    //         double.parse(widget.product["ratings"].toString()),
                    //     itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                    //     itemBuilder: (context, _) => Icon(
                    //       MdiIcons.star,
                    //       size: 10,
                    //       color: Colors.redAccent,
                    //     ),
                    //     onRatingUpdate: (rating) {
                    //       //print(rating);
                    //     },
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 3,
                    // ),
                    Row(
                      children: [
                        if (widget.product["offer_price"] != null) ...{
                          Container(
                            child: Text(
                              discount(
                                      widget.product["price"].toString(),
                                      widget.product["offer_price"]
                                          .toString()) +
                                  "% Off ",
                              style: GoogleFonts.poppins(
                                  color: Colors.greenAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
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
                    )
                    // Row(
                    //   children: [
                    //     Icon(
                    //       MdiIcons.starCircle,
                    //       color: Colors.green,
                    //       size: 18,
                    //     ),
                    //     Text(
                    //       "${widget.audio['ratings'].toString()} (${widget.audio['view_count'].toString()} listens) ${widget.audio['duration'].toString()} min",
                    //       style: GoogleFonts.poppins(
                    //           color: TEXT_WHITE_SHADE, fontSize: 14),
                    //     )
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 3,
                    // ),
                    // Text(
                    //   widget.audio['short_description'].toString(),
                    //   maxLines: 3,
                    //   overflow: TextOverflow.leftToRight,
                    //   style: GoogleFonts.poppins(
                    //       color: TEXT_WHITE_SHADE, fontSize: 12),
                    // )
                  ],
                ))
          ]),
        ));
  }
}
