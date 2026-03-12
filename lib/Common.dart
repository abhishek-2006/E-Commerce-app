import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

Widget appButton({required String buttonText, Function()? onPressed, Color bgColor = Colors.blue, double radius = 12}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      margin: EdgeInsets.symmetric(
        vertical: 20,
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
      child: Center(
        child: Text(
          "${buttonText}",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    ),
  );
}

showErrorMsg(String error) {
  Fluttertoast.showToast(
      msg: "${error}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.lightBlueAccent,
      textColor: Colors.white,
      fontSize: 16.0);
}

// ios design
void imageSelectionActionSheet({required BuildContext context, required Function() camera, required Function() gallery}) {
  final action = CupertinoActionSheet(
    title: const Text("Select Files"),
    actions: <Widget>[
      CupertinoActionSheetAction(
        child: Text(
          "Camera",
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          camera();
        },
      ),
      CupertinoActionSheetAction(
        child: Text(
          "Image",
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          gallery();
        },
      ),
    ],
    cancelButton: CupertinoActionSheetAction(
      isDestructiveAction: true,
      isDefaultAction: true,
      child: Text(
        "Cancel",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  );
  showCupertinoModalPopup(context: context, builder: (context) => action);
}

// android design
void showDialogImageSelection({required BuildContext context, required Function() camera, required Function() gallery}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          content: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            width: double.maxFinite,
            child: ListView(shrinkWrap: true, children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.camera,
                  color: Colors.blue,
                ),
                title: Text(
                  "camera",
                  style: TextStyle(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  camera!();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.image,
                  color: Colors.blue,
                ),
                title: Text(
                  "images",
                ),
                onTap: () {
                  Navigator.pop(context);
                  gallery!();
                },
              ),
            ]),
          ),
        );
      });
}

bool isPlatformIOS() {
  // import io not html
  if (Platform.isIOS) {
    return true;
  } else {
    return false;
  }
}

showProgressDialog(BuildContext context) async {
  final alert = AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    contentPadding: EdgeInsets.zero,
    insetPadding: EdgeInsets.symmetric(horizontal: 24),
    content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
          ],
        )),
  );

  showDialog(
    useRootNavigator: false,
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

hideProgress(BuildContext context) {
  Navigator.pop(context);
}

Future<dynamic> getImage(int i) async {
  final ImagePicker picker = new ImagePicker();

  try {
    if (i == 0) {
      return await picker.pickImage(source: ImageSource.camera);
    } else {
      return await picker.pickImage(source: ImageSource.gallery);
    }
  } catch (e) {}
}
