import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../Common.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  var formkey = GlobalKey<FormState>();

  // import must io not hrml
  File? selectedFile = null;

  TextEditingController productNameCotroller = TextEditingController();
  TextEditingController productPriceCotroller = TextEditingController();
  TextEditingController productDescriptionCotroller = TextEditingController();
  TextEditingController productRatingCotroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          "Add Product",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formkey,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 2),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        child: Center(
                          child: selectedFile == null
                              ? Image.asset(
                            "assets/add_image.png",
                            height: 200,
                            width: 200,
                          )
                              : Image.file(
                            selectedFile!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onTap: () {
                          imageSelectionActionSheet(
                            context: context,
                            camera: () async {
                              var image = await getImage(0);
                              if (image != null) {
                                setState(() {
                                  selectedFile = File(image.path);
                                });
                              }
                            },
                            gallery: () async {
                              var image = await getImage(1);
                              if (image != null) {
                                setState(() {
                                  selectedFile = File(image.path);
                                });
                              }
                            },
                          );
                        },
                      ),
                      SizedBox(
                        height: 16,
                      ),

                      //
                      TextFormField(
                        controller: productNameCotroller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Invalid Product Name";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: "Product Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      //
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: productDescriptionCotroller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Invalid desc";
                          }
                          return null;
                        },
                        textAlign: TextAlign.start,
                        minLines: 4,
                        maxLines: 10,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: "Product Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      //
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: productPriceCotroller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Invalid Price";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: "Product Price",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      //
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: productRatingCotroller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Invalid Rating";
                          }

                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: "Product Rating",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      //
                      appButton(
                          buttonText: "Add",
                          onPressed: () async {
                            if (formkey.currentState!.validate() == true) {
                              showProgressDialog(context);

                              // add data into database

                              var imageUrl = "";
                              var datetime = DateTime.now().millisecondsSinceEpoch;

                              final ref = FirebaseStorage.instance.ref().child('user_images').child('${datetime}.jpg');

                              if (selectedFile != null) {
                                try {
                                  await ref.putFile(selectedFile!);
                                } on FirebaseException catch (e) {
                                  print(e);
                                }
                                imageUrl = await ref.getDownloadURL();
                              }

                              CollectionReference users = FirebaseFirestore.instance.collection('products');
                              await users.add({
                                'product_image': imageUrl,
                                'product_name': productNameCotroller.text.toString(),
                                'product_desc': productDescriptionCotroller.text.toString(),
                                'product_price': productPriceCotroller.text.toString(),
                                'product_rate': productRatingCotroller.text.toString(),
                              });

                              showErrorMsg("Product Added success");
                              hideProgress(context);
                              Navigator.pop(context);
                            }
                          })
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
