import 'dart:async';
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
import 'package:vidventure/pages/FullScreenImagePage.dart';
import 'package:vidventure/pages/discovery_page.dart';
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
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? pickedFile;
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
  bool canUploadImage = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _checkUserExistence();
    _getImages();
    _getFollowingCount();
    joinedorNot(FirebaseAuth.instance.currentUser!.uid);
    gettinguserdata();
    _initBannerAd();
    _startImageUploadNotificationTimer();
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
        adUnitId: 'ca-app-pub-8996334303873561/3087234311',
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

  void _startImageUploadNotificationTimer() {
    // Notify user to upload an image suddenly every day
    Timer.periodic(Duration(days: 1), (timer) {
      _showImageUploadNotification();
    });
  }

  void _showImageUploadNotification() {
    // Notify user to upload an image suddenly
    if (mounted && canUploadImage) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Image Upload"),
            content: Text("It's time to upload an image!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _redirectToCamera();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void _redirectToCamera() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        pickedFile = pickedImage;
      });

      await uploadFle(); // Corrected method name
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "RawLens",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
          Text("Capture the Moment: Selfie or Photo"),
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
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade50,
                            Colors.purple.shade50,
                          ], // Light gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Center(
                        child: Text(
                          "Follow",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
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
                  if (canUploadImage) {
                    await uploadFle();
                  }
                },
                child: Icon(Icons.add_a_photo),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    canUploadImage
                        ? Colors.blue
                            .shade50 // Light blue shade when upload is allowed
                        : Colors.purple
                            .shade50, // Light purple shade when upload is not allowed
                  ),
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
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        int reversedIndex = _imageUrls.length - 1 - index;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImagePage(
                                  imageUrl: _imageUrls[reversedIndex],
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              _imageUrls[reversedIndex],
                              fit: BoxFit.cover,
                            ),
                          ),
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
            Container(
              width: 150, // Icon width
              height: 150, // Icon height
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.purple.shade50
                  ], // Apply gradient here
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.account_circle,
                  size: 100, // Icon size
                  color:
                      Colors.white, // Icon color will remain white to stand out
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              username,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
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
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
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
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
          padding: EdgeInsets.symmetric(vertical: 50),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ), // Adds spacing
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(30), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color
                blurRadius: 10, // Softness of the shadow
                spreadRadius: 2, // Shadow spread
                offset: Offset(0, 4), // Shadow position
              ),
            ],
          ),
          padding:
              const EdgeInsets.symmetric(vertical: 18), // Padding inside navbar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.home, color: Colors.grey),
              GestureDetector(
                onTap: () {
                  nextScreenReplacement(
                    context,
                    GetFollowingPage(
                        uid: FirebaseAuth.instance.currentUser!.uid),
                  );
                },
                child: Icon(Icons.favorite),
              ),
              GestureDetector(
                onTap: () {
                  nextScreenReplacement(
                    context,
                    GetFollowersPage(
                        uid: FirebaseAuth.instance.currentUser!.uid),
                  );
                },
                child: Icon(Icons.people),
              ),
              GestureDetector(
                onTap: () {
                  nextScreenReplacement(context, DiscoveryPage());
                },
                child: Icon(Icons.explore),
              ),
              // GestureDetector(
              //   onTap: () {
              //     nextScreenReplacement(
              //       context,
              //       UserProfilePage(
              //         username: username!,
              //         uid: FirebaseAuth.instance.currentUser!.uid,
              //       ),
              //     );
              //   },
              //   child: Icon(Icons.person),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // ... existing code

  Future uploadFle() async {
    if (pickedFile == null || !canUploadImage) {
      // Handle the case where no image is selected
      return;
    }

    String path =
        "users/${FirebaseAuth.instance.currentUser?.uid}/profilepic/${pickedFile!.name}";

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(File(pickedFile!.path));

    final snapshot = await uploadTask!.whenComplete(() {});
    setState(() async {
      urlDownload = await snapshot.ref.getDownloadURL();
    });
    print("Downloadlink: $urlDownload");
    return Image.network(urlDownload);
  }

  Future _selectanimage() async {
    final result = await ImagePicker().pickImage(source: ImageSource.camera);
    if (result == null) return;

    setState(() {
      pickedFile = result;
      canUploadImage = true;
    });
  }
}
