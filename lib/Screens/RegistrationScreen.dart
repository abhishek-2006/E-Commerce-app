import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Common.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  var isPassVisible = true;
  var isConfirmPassVisible = true;

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  String selectedGender = "";

  var formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formkey,
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
                    "Sign Up",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),

                //
                SizedBox(
                  height: 16,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        //
                        TextFormField(
                          controller: nameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Invalid Name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: "Name",
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
                          controller: emailController,
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

                        //
                        SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          obscureText: isPassVisible,
                          controller: passwordController,
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
                            labelText: "Password",
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
                          controller: cPasswordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Invalid Confirm Password";
                            } else if (passwordController.text.toString() != value) {
                              return "Password and confirm password should be same.";
                            }
                            return null;
                          },
                          obscureText: isConfirmPassVisible,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: "Confirm Password",
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

                        //
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          "Gender",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),

                        Row(
                          children: [
                            //
                            Expanded(
                                child: Row(
                                  children: [
                                    Radio(
                                        value: "male",
                                        groupValue: selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value!;
                                          });
                                        }),
                                    Text("Male")
                                  ],
                                )),

                            //
                            Expanded(
                                child: Row(
                                  children: [
                                    Radio(
                                        value: "female",
                                        groupValue: selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value!;
                                          });
                                        }),
                                    Text("Female"),
                                  ],
                                )),
                            Expanded(
                                child:Row(
                                  children: [
                                    Radio(
                                        value: "other",
                                        groupValue: selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value!;
                                          });
                                        }),
                                    Text("Other"),
                                  ],
                                ),
                            ),
                          ],
                        ),

                        //
                        appButton(
                            buttonText: "Register",
                            onPressed: () async {
                              if (formkey.currentState!.validate() == true) {
                                showProgressDialog(context);

                                var userData = await FirebaseFirestore.instance
                                    .collection('users')
                                    .where(
                                  'email',
                                  isEqualTo: emailController.text.toString(),
                                )
                                    .get();
                                if (userData.docs.length > 0) {
                                  hideProgress(context);
                                  showErrorMsg("User is already registered");
                                } else {
                                  // add data into database
                                  CollectionReference users = FirebaseFirestore.instance.collection('users');
                                  await users.add({
                                    'name': nameController.text.toString(),
                                    'email': emailController.text.toString(),
                                    'pass': passwordController.text.toString(),
                                    'gender': selectedGender,
                                  });

                                  showErrorMsg("Registered successfully");
                                  hideProgress(context);
                                  Navigator.pop(context);
                                }
                              }
                            })
                      ],
                    ),
                  ),
                ),

                //
                SizedBox(
                  height: 16,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text.rich(
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Already have an account? ",
                          // style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
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
