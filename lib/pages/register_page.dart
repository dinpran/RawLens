import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vidventure/auth/auth_services.dart';
import 'package:vidventure/auth/database_services.dart';
import 'package:vidventure/helper/helper_function.dart';
import 'package:vidventure/pages/home_page.dart';
import 'package:vidventure/pages/login_page.dart';
import 'package:vidventure/widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formkey = GlobalKey<FormState>();
  TextEditingController _fullnamecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  String _username = "";
  String _email = "";
  String _password = "";
  final AuthServices _authServices = AuthServices();
  bool isloading = false;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Page"),
        centerTitle: true,
      ),
      body: Form(
        key: formkey,
        child: isloading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Image.asset("assets/register.png"),
                      TextFormField(
                        controller: _fullnamecontroller,
                        decoration: textInputDecoration.copyWith(
                          labelText: "Name",
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _username = value;
                          });
                        },
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            return "Username cannot be null or the username already exists";
                          }
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _emailcontroller,
                        decoration: textInputDecoration.copyWith(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _email = value;
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
                            _password = value;
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
                                register();
                              },
                              child: Text("Signup"))),
                      Text.rich(TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "LogIn!",
                                style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreenReplacement(context, LoginPage());
                                  })
                          ]))
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future register() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      await _authServices
          .registeruser(_username, _email, _password)
          .then((value) async {
        if (value == true) {
          await HelperFunctions.saveUsername(_username);
          await HelperFunctions.saveEmail(_email);
          await HelperFunctions.saveUserLoggedInStatus(true);
          nextScreenReplacement(context, HomePage());
        } else {
          showSnackBar(context, Colors.red, value);
          setState(() {
            isloading = false;
          });
        }
      });
    }
  }
}
