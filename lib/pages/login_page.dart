import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vidventure/auth/auth_services.dart';
import 'package:vidventure/auth/database_services.dart';
import 'package:vidventure/helper/helper_function.dart';
import 'package:vidventure/pages/home_page.dart';
import 'package:vidventure/pages/register_page.dart';
import 'package:vidventure/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formkey = GlobalKey<FormState>();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  String email = "";
  String password = "";
  bool _isloading = false;
  AuthServices _authServices = AuthServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
        centerTitle: true,
      ),
      body: Form(
        key: formkey,
        child: _isloading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Image.asset("assets/login.png"),
                      TextFormField(
                        controller: _emailcontroller,
                        decoration: textInputDecoration.copyWith(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        validator: (val) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(val!)
                              ? null
                              : "Please enter a valid email";
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _passwordcontroller,
                        obscureText: true,
                        decoration: textInputDecoration.copyWith(
                          labelText: "password",
                          prefixIcon: Icon(Icons.lock),
                        ),
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        validator: (value) {
                          if (value!.length < 6) {
                            return "password should be less than 6 characters";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                login();
                              },
                              child: Text("Login"))),
                      Text.rich(TextSpan(
                          text: "Don't Have an Account? ",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "Register!",
                                style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreenReplacement(
                                        context, RegisterPage());
                                  })
                          ]))
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future login() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });
      await _authServices.loginuser(email, password).then((value) async {
        if (value == true) {
          QuerySnapshot snapshot = await DatabaseServices(
                  uid: FirebaseAuth.instance.currentUser!.uid)
              .gettinguserdata(email);
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveEmail(email);
          await HelperFunctions.saveUsername(snapshot.docs[0]["fullname"]);
          nextScreenReplacement(context, HomePage());
        } else {
          showSnackBar(context, Colors.red, value);
          setState(() {
            _isloading = false;
          });
        }
      });
    }
  }
}
