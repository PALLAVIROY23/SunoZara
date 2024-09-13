import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/product/order_details.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../api/api_constant.dart';
import '../dashboard.dart';
import '../dashboard_tab.dart';
import '../placeholders.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool loaded = false;
  dynamic orders = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() {
    ApiService().orders().then((value) => sOrd(value));
  }

  sOrd(value) {
    setState(() {
      orders = value['orders'];
      loaded = true;
    });
  }

  loadDatar() {
    setState(() {
      loaded = false;
      orders = [];
    });
    ApiService().orders().then((value) => sOrdr(value));
  }

  sOrdr(value) async {
    setState(() {
      orders = value['orders'];
      loaded = true;
    });
    await Future.delayed(Duration(milliseconds: 2000));
    _refreshController.loadComplete();
  }

  void _onRefresh() async {
    // monitor network fetch
    loadData();
    // if failed,use refreshFailed()
    await Future.delayed(Duration(milliseconds: 2000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    loadData();
    if (mounted) {}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color.fromARGB(255, 237, 235, 235),
              foregroundColor: Colors.black,
              title: Text("Orders"),
              // automaticallyImplyLeading: false,
              // centerTitle: true,
              actions: [],
            ),
            body: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropHeader(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView(
                children: [
                  if (loaded) ...{
                    if (orders.length > 0) ...{
                      for (int i = 0; i < orders.length; i++) ...{
                        for (int j = 0; j < orders[i]['items'].length; j++) ...{
                          if (orders[i]['items'][j]['item'] != null) ...{
                            Container(
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.leftToRight,
                                          alignment: Alignment.bottomCenter,
                                          child: OrderSummaryPage(
                                            order: orders[i],
                                            item: orders[i]['items'][j],
                                          )));
                                },
                                leading: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10)),
                                  height: 60,
                                  width: 60,
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: ApiConstants.storagePATH +
                                        "/products/" +
                                        orders[i]['items'][j]['item']['image']
                                            .toString(),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            enabled: true,
                                            child: SingleChildScrollView(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              child: BannerPlaceholder(60, 60),
                                            )),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                                trailing: Icon(Icons.chevron_right),
                                title: Text(
                                  orders[i]['items'][j]['item']['name']
                                      .toString(),
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order Date: ${DateFormat('dd-MMM-yyyy').format(DateTime.parse(orders[i]['items'][j]['created_at'].toString().split(' ')[0]))}",
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                    if (orders[i]['items'][j]['status']
                                            .toString() ==
                                        'accepted') ...{
                                      Text(
                                        orders[i]['items'][j]['status']
                                            .toString()
                                            .toUpperCase(),
                                        style: GoogleFonts.poppins(
                                            color: Colors.blue, fontSize: 12),
                                      )
                                    } else if (orders[i]['items'][j]['status']
                                            .toString() ==
                                        'refunded') ...{
                                      Text(
                                        orders[i]['items'][j]['status']
                                            .toString()
                                            .toUpperCase(),
                                        style: GoogleFonts.poppins(
                                            color: Colors.redAccent,
                                            fontSize: 12),
                                      )
                                    } else if (orders[i]['items'][j]['status']
                                            .toString() ==
                                        'cancelled') ...{
                                      Text(
                                        orders[i]['items'][j]['status']
                                            .toString()
                                            .toUpperCase(),
                                        style: GoogleFonts.poppins(
                                            color: Colors.redAccent,
                                            fontSize: 12),
                                      )
                                    } else if (orders[i]['items'][j]['status']
                                            .toString() ==
                                        'delivered') ...{
                                      Text(
                                        orders[i]['items'][j]['status']
                                            .toString()
                                            .toUpperCase(),
                                        style: GoogleFonts.poppins(
                                            color: Colors.green, fontSize: 12),
                                      )
                                    } else ...{
                                      Text(
                                        orders[i]['items'][j]['status']
                                            .toString()
                                            .toUpperCase(),
                                        style: GoogleFonts.poppins(
                                            color: Colors.black, fontSize: 12),
                                      )
                                    }
                                  ],
                                ),
                              ),
                            ),
                            Divider()
                          }
                        }
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
                              "No orders found.",
                              style: GoogleFonts.poppins(
                                  color: Colors.black.withOpacity(0.5),
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
                                  width: MediaQuery.of(context).size.width - 20,
                                  lineType: ContentLineType.threeLines,
                                ),
                              ],
                            ),
                          )),
                    }
                  }
                ],
              ),
            )));
  }
}
