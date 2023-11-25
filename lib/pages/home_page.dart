import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vidventure/auth/auth_services.dart';
import 'package:vidventure/auth/database_services.dart';
import 'package:vidventure/auth/storage_services.dart';
import 'package:vidventure/helper/helper_function.dart';
import 'package:vidventure/pages/followers_page.dart';
import 'package:vidventure/pages/following_page.dart';
import 'package:vidventure/pages/getfollowers_page.dart';
import 'package:vidventure/pages/getfollowing_page.dart';
import 'package:vidventure/pages/login_page.dart';
import 'package:vidventure/pages/profile_page.dart';
import 'package:vidventure/pages/search_page.dart';
import 'package:vidventure/pages/userprofile_page.dart';
import 'package:vidventure/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  var urlDownload;
  Stream<QuerySnapshot>? images;
  late List<String> _imageUrls = [];
  int followers = 0;
  int posts = 0;
  int following = 0;
  late List<String> _followers = [];
  late List<String> _following = [];
  bool isJoined = false;
  String username = "";
  String email = "";
  AuthServices authService = AuthServices();
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  void initState() {
    super.initState();
    _loadImages();
    _checkUserExistence();
    _getImages();
    _getFollowingCount();
    joinedorNot(FirebaseAuth.instance.currentUser!.uid);
    gettinguserdata();
    _initBannerAd();
  }

  Future<void> _loadImages() async {
    final StorageService _storageService =
        StorageService(uid: FirebaseAuth.instance.currentUser!.uid);
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

  Future<void> _getImages() async {
    final StorageService _storageService =
        StorageService(uid: FirebaseAuth.instance.currentUser!.uid);
    List<String> imageUrls = await _storageService.listAllImages();
    setState(() {
      posts = imageUrls.length;
    });
  }

  Future<void> _checkUserExistence() async {
    int userExists = await DatabaseServices()
        .getFollowersCount(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      followers = userExists;
    });
  }

  Future<void> _getFollowingCount() async {
    int userExists = await DatabaseServices()
        .getFollowingsCount(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      following = userExists;
    });
  }

  joinedorNot(String groupId) {
    DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .isUserJoined(groupId)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
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
        title: Text("HomePage"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(context, SearchPage());
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  nextScreen(
                      context,
                      FollowersPage(
                          uid: FirebaseAuth.instance.currentUser!.uid));
                },
                child: Column(
                  children: [
                    Text(
                      "Followers",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("${followers}")
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    "Posts",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("${posts}")
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      nextScreen(
                          context,
                          FollowingPage(
                              uid: FirebaseAuth.instance.currentUser!.uid));
                    },
                    child: Text(
                      "Following",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text("${following}")
                ],
              ),
            ],
          ),
          Text("Select and image to upload"),
          SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: () async {
              await DatabaseServices(
                      uid: FirebaseAuth.instance.currentUser!.uid)
                  .toggleGroupJoin(
                FirebaseAuth.instance.currentUser!.uid,
              );
              if (isJoined) {
                setState(() {
                  isJoined = !isJoined;
                });
                showSnackBar(context, Colors.red, "Unfollowing");
              } else {
                setState(() {
                  isJoined = !isJoined;
                });
                showSnackBar(context, Colors.green, "Successfully Following");
              }
            },
            child: isJoined
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.grey,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Center(
                        child: const Text(
                          "Following",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Center(
                        child: const Text("Follow",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _selectanimage();
                  await uploadFle();
                },
                child: Icon(Icons.upload),
                // child: Text("Select an image to Upload"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.white.withOpacity(1)),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          _imageUrls == null
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
      drawer: Drawer(
        child: ListView(
          children: [
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              username,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {},
              selected: true,
              selectedColor: Theme.of(context).primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group),
              title: Text(
                "Home",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreen(
                    context,
                    ProfilePage(
                      username: username,
                      email: email,
                    ));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.person),
              title: Text(
                "Profile",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            ListTile(
              onTap: () async {
                await authService.signout();
                nextScreenReplacement(context, LoginPage());
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.logout),
              title: Text(
                "Logout",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
          padding: EdgeInsets.symmetric(vertical: 50),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: Icon(
              Icons.home,
              color: Colors.red,
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
          GestureDetector(
              onTap: () {
                nextScreenReplacement(
                    context,
                    UserProfilePage(
                        username: username!,
                        uid: FirebaseAuth.instance.currentUser!.uid));
              },
              child: Container(
                child: Icon(Icons.person),
              ))
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
