import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Common.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var isPassVisible = true;
  var isConfirmPassVisible = true;
  TextEditingController emailCotroller = new TextEditingController();
  TextEditingController passwordCotroller = TextEditingController();
  TextEditingController confirmPasswordCotroller = TextEditingController();

  var formkey = GlobalKey<FormState>();

  bool showPasswordFields = false;
  bool isEmailReadOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //
              SizedBox(
                height: 16,
              ),
              Center(
                child: Text(
                  "Forgot Password",
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 2),
                  ],
                ),
                child: Center(
                  child: Form(
                    key: formkey,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        //
                        TextFormField(
                          readOnly: showPasswordFields,
                          controller: emailCotroller,
                          validator: (value) {
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        if (showPasswordFields == true)
                          Column(
                            children: [
                              //
                              SizedBox(
                                height: 16,
                              ),
                              TextFormField(
                                controller: passwordCotroller,
                                obscureText: isPassVisible,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Invalid Password";
                                  } else if (value!.length < 6) {
                                    return "Min. lenght should be 6.";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelText: "New Password",
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
                              TextFormField(
                                controller: confirmPasswordCotroller,
                                obscureText: isConfirmPassVisible,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Invalid Confim Password";
                                  } else if (passwordCotroller.text.toString() != value) {
                                    return "Password and confirm password shoould be same.";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelText: "Confirm New Password",
                                  suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isConfirmPassVisible == true) {
                                            isConfirmPassVisible = false;
                                          } else {
                                            isConfirmPassVisible = true;
                                          }
                                        });
                                      },
                                      child: Icon(isConfirmPassVisible ? Icons.visibility : Icons.visibility_off_outlined)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        appButton(
                            buttonText: "Login",
                            onPressed: () async {
                              if (formkey.currentState!.validate() == true) {
                                showProgressDialog(context);

                                var userData = await FirebaseFirestore.instance
                                    .collection('users')
                                    .where(
                                  'email',
                                  isEqualTo: emailCotroller.text.toString(),
                                )
                                    .get();

                                if (userData.docs.length > 0) {
                                  if (showPasswordFields == true) {
                                    var user = userData.docs[0];
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.id)
                                        .update({'pass': passwordCotroller.text.toString()});

                                    hideProgress(context);
                                    showErrorMsg("Password reset successfully.");
                                    Navigator.pop(context);
                                  } else {
                                    hideProgress(context);
                                    setState(() {
                                      showPasswordFields = true;
                                      isEmailReadOnly = true;
                                    });
                                  }
                                } else {
                                  hideProgress(context);
                                  showErrorMsg("User not found");
                                }
                              }
                            })
                      ],
                    ),
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
