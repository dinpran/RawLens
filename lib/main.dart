import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vidventure/helper/helper_function.dart';
import 'package:vidventure/pages/home_page.dart';
import 'package:vidventure/pages/login_page.dart';
import 'package:vidventure/pages/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _issignedin = false;
  @override
  void initState() {
    // TODO: implement initState
    HelperFunctions.getUserLoggenInStatus().then((value) {
      setState(() {
        _issignedin = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _issignedin ? HomePage() : LoginPage(),
    );
  }
}
