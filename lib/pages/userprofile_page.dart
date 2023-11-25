import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vidventure/auth/auth_services.dart';
import 'package:vidventure/auth/database_services.dart';
import 'package:vidventure/auth/storage_services.dart';
import 'package:vidventure/helper/helper_function.dart';
import 'package:vidventure/pages/followers_page.dart';
import 'package:vidventure/pages/following_page.dart';
import 'package:vidventure/pages/getfollowers_page.dart';
import 'package:vidventure/pages/getfollowing_page.dart';
import 'package:vidventure/pages/home_page.dart';
import 'package:vidventure/pages/login_page.dart';
import 'package:vidventure/pages/profile_page.dart';
import 'package:vidventure/pages/search_page.dart';
import 'package:vidventure/widgets/widgets.dart';

class UserProfilePage extends StatefulWidget {
  final String username;
  final String uid;
  UserProfilePage({super.key, required this.username, required this.uid});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String username = "";
  String email = "";
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  var urlDownload;
  Stream<QuerySnapshot>? images;
  final StorageService _storageService =
      StorageService(uid: FirebaseAuth.instance.currentUser!.uid);
  late List<String> _imageUrls = [];
  AuthServices authService = AuthServices();
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  void initState() {
    super.initState();
    _loadImages();
    gettinguserdata();
    _initBannerAd();
  }

  Future<void> _loadImages() async {
    List<String> imageUrls = await _storageService.listAllImages();
    setState(() {
      _imageUrls = imageUrls;
    });
  }

  _initBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: 'ca-app-pub-8996334303873561/6779668050',
        listener: BannerAdListener(
            onAdLoaded: (ad) {
              setState(() {
                _isAdLoaded = true;
              });
            },
            onAdFailedToLoad: ((ad, error) {})),
        request: AdRequest());
    _bannerAd.load();
  }

  gettinguserdata() async {
    await HelperFunctions.getUserEmailKey().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNamelKey().then((value) {
      setState(() {
        username = value!;
      });
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$username"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await _selectanimage();
              await uploadFle();
            },
            child: Icon(Icons.upload),
            // child: Text("Select an image to Upload"),
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.white.withOpacity(1)),
            ),
          ),
          Text("Select and image to upload"),
          _imageUrls == null
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Number of images in each row
                        crossAxisSpacing:
                            4.0, // Spacing between each image horizontally
                        mainAxisSpacing:
                            4.0, // Spacing between each image vertically
                      ),
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        int reversedIndex = _imageUrls.length - 1 - index;
                        return Image.network(
                          _imageUrls[reversedIndex],
                          fit: BoxFit.cover, // Adjust the image's fit as needed
                        );
                      },
                    ),
                  ),
                ),
          _isAdLoaded
              ? Container(
                  height: _bannerAd.size.height.toDouble(),
                  width: _bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                )
              : SizedBox(),
          SizedBox(
            height: 20,
          )
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              nextScreenReplacement(context, HomePage());
            },
            child: Container(
              child: Icon(
                Icons.home,
              ),
            ),
          ),
          GestureDetector(
              onTap: () {
                nextScreenReplacement(
                    context,
                    GetFollowingPage(
                        uid: FirebaseAuth.instance.currentUser!.uid));
              },
              child: Container(
                child: Icon(Icons.favorite),
              )),
          GestureDetector(
              onTap: () {
                nextScreenReplacement(
                    context,
                    GetFollowersPage(
                        uid: FirebaseAuth.instance.currentUser!.uid));
              },
              child: Container(
                child: Icon(Icons.people),
              )),
          Container(
            child: Icon(
              Icons.person,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  Future uploadFle() async {
    final file = File(pickedFile!.path!);
    String path =
        "users/${FirebaseAuth.instance.currentUser?.uid}/profilepic/${pickedFile!.name}";

    final ref = FirebaseStorage.instance.ref().child(path); //path!
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});
    setState(() async {
      urlDownload = await snapshot.ref.getDownloadURL();
    });
    // var urlDownload = await snapshot.ref.getDownloadURL();
    print("Downloadlink: $urlDownload");
    return Image.network(urlDownload);
  }

  Future _selectanimage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }
}
