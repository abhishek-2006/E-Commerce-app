import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common.dart';
import 'DashboardScreen.dart';
import 'RegistrationScreen.dart';
import 'ForgotPassword.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var isPassVisible = true;
  TextEditingController emailCotroller = new TextEditingController();
  TextEditingController passwordCotroller = TextEditingController();

  var formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //
                SizedBox(
                  height: 25,
                ),
                Center(
                  child: Image.asset(
                    "assets/login.png",
                    height: 100,
                    width: 100,
                  ),
                ),
                Center(
                  child: Text(
                    "Welcome Back",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),

                //
                SizedBox(
                  height: 120,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),

                  child: Center(
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //
                          TextFormField(
                            controller: emailCotroller,
                            validator: (value) {
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              if (value!.isEmpty) {
                                return "Invalid Email";
                              } else if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!) ==
                                  false) {
                                return "Invalid Email format";
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: "Email",
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.blueAccent,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          //
                          SizedBox(
                            height: 18,
                          ),
                          TextFormField(
                            controller: passwordCotroller,
                            obscureText: isPassVisible,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Invalid Password";
                              } else if (value!.length < 6) {
                                return "Min. length should be 6.";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: "Password",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.blueAccent,
                              ),
                              suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isPassVisible == true) {
                                        isPassVisible = false;
                                      } else {
                                        isPassVisible = true;
                                      }
                                    });
                                  },
                                  child: Icon(isPassVisible ? Icons.visibility : Icons.visibility_off_outlined)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          //
                          SizedBox(
                            height: 16,
                          ),
                          appButton(
                              buttonText: "Login",
                              onPressed: () async {
                                if (formkey.currentState!.validate() == true) {
                                  showProgressDialog(context);

                                  try {
                                    // Step 1: Check if email exists
                                    var emailQuery = await FirebaseFirestore.instance
                                        .collection('users')
                                        .where('email', isEqualTo: emailCotroller.text.trim())
                                        .get();

                                    if (emailQuery.docs.isEmpty) {
                                      hideProgress(context);
                                      showErrorMsg("User not found");
                                    } else {
                                      // Step 2: Check if password matches
                                      var userDoc = emailQuery.docs.first;
                                      var mapData = userDoc.data();

                                      if (mapData['pass'] == passwordCotroller.text.trim()) {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        await prefs.setString('email', mapData['email']);
                                        await prefs.setString('name', mapData['name']);

                                        hideProgress(context);
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (context) => DashboardScreen()), (Route<dynamic> route) => false,
                                        );
                                        showErrorMsg("Logged in successfully");
                                      } else {
                                        hideProgress(context);
                                        showErrorMsg("Password is incorrect");
                                      }
                                    }
                                  } catch (e) {
                                    hideProgress(context);
                                    showErrorMsg("Something went wrong");
                                  }
                                }
                              }),
                        ],
                      ),
                    ),
                  ),
                ),

                //
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgotPassword()));
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text.rich(
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Forgot Password?",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //
                SizedBox(
                  height: 28,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegistrationScreen()));
                  },
                  child: Text.rich(
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          // style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Register Now',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
