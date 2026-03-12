import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common.dart';
import 'AddProduct.dart';
import 'LoginScreen.dart';

import '../Models/ProductModel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var key = GlobalKey<ScaffoldState>();

  bool isNoData = false;
  bool isLoading = false;

  List<ProductModel> allData = [];

  var sliderImages = [
    'assets/slider1.jpeg',
    'assets/slider2.jpeg',
    'assets/slider3.jpeg',
  ];

  Future<void> getProducts() async {
    setState(() {
      isLoading = true;
    });
    var productData = await FirebaseFirestore.instance.collection('products').get();

    isLoading = false;

    if (productData.docs.length > 0) {
      isNoData = false;
      allData.clear();
      productData.docs.forEach((element) {
        var data = element.data();

        ProductModel productModel = ProductModel();

        productModel.id = element.reference.id;
        productModel.image = data["product_image"];
        productModel.name = data["product_desc"];
        productModel.price = data["product_name"];
        productModel.desc = data["product_price"];
        productModel.ratings = data["product_rate"];
        allData.add(productModel);
      });
    } else {
      isNoData = true;
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProducts();
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit(0);
        return false;
      },
      child: Scaffold(
        key: key,
        drawer: Drawer(
          child: ListView(
            children: [
              //
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
              ),

              //
              ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddProduct()));
                },
                leading: Icon(Icons.add_box_outlined),
                title: Text("Add Product"),
              ),

              //
              ListTile(
                leading: Icon(Icons.add_shopping_cart),
                title: Text("Fav Product"),
              ),

              //
              ListTile(
                onTap: () {
                  var dialog = AlertDialog(
                    content: Text("Do you want to logout?"),
                    actions: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(); // Just dismiss the dialog
                        },
                        child: Text("No"),
                      ),

                      GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.clear();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => LoginScreen()), (Route<dynamic> route) => false,
                          );
                          },
                        child: Text("Yes"),
                      ),
                    ],
                  );

                  showDialog(
                    context: context,
                    builder: (builder) {
                      return dialog;
                      },
                  );
                  },
                leading: Icon(Icons.logout),
                title: Text("Logout"),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              key.currentState!.openDrawer();
            },
            child: Icon(
              Icons.menu_outlined,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue,
          title: Text(
            "Home",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 16),
              child: CarouselSlider.builder(
                itemCount: sliderImages.length,
                itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) => Container(
                  child: Container(
                    // margin: EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        sliderImages[itemIndex],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                options: CarouselOptions(
                  height: 100,
                  onPageChanged: (index, value) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  disableCenter: true,
                  // aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: currentIndex,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  // autoPlayAnimationDuration: Duration(milliseconds: 800),
                  // autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),

            SizedBox(
              height: 12,
            ),
            DotsIndicator(
              dotsCount: sliderImages.length,
              position: currentIndex,
              decorator: DotsDecorator(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                size: Size(10, 10),
              ),
            ),
            Expanded(
              child: Container(
                child: isLoading == true
                    ? Center(child: CircularProgressIndicator())
                    : isNoData == true
                    ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("no Data Found"),
                          appButton(
                              buttonText: "Refresh",
                              onPressed: () {
                                getProducts();
                              })
                        ],
                      ),
                    ))
                    : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: allData!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var singleData = allData![index];
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 2),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            singleData.image!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Container(
                                height: 100,
                                width: 100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Name : ${singleData.name}"),
                                Text("desc : ${singleData.desc}"),
                                Text("Price : ${singleData.price} Rupees"),
                                Text("Ratings : ${singleData.ratings} / 10"),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            children: [
                              GestureDetector(onTap: () {}, child: Icon(Icons.add_shopping_cart)),
                              SizedBox(
                                height: 16,
                              ),
                              GestureDetector(
                                  onTap: () {
                                    var dialog = AlertDialog(
                                      content: Text("Do you want to delete?"),
                                      actions: [
                                        GestureDetector(
                                            onTap: () async {
                                              Navigator.pop(context);

                                              showProgressDialog(context);
                                              var productData = await FirebaseFirestore.instance
                                                  .collection('products')
                                                  .doc("${singleData.id}")
                                                  .delete();

                                              hideProgress(context);
                                              getProducts();
                                            },
                                            child: Text("Delete")),
                                      ],
                                    );

                                    showDialog(
                                        context: context,
                                        builder: (builder) {
                                          return dialog;
                                        });
                                  },
                                  child: Icon(Icons.delete)),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
