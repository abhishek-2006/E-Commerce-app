import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DashboardScreen.dart';
import 'LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  checkIsLogin() async {
    Future.delayed(Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var email = prefs.getString('email');
      if (email != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardScreen()));
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIsLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Image.asset(
              "assets/splash.png",
              height: 200,
              width: 200,
            )),
      ),
    );
  }
}
