import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vidventure/auth/database_services.dart';
import 'package:vidventure/auth/storage_services.dart';
import 'package:vidventure/pages/FullScreenImagePage.dart';
import 'package:vidventure/pages/followers_page.dart';
import 'package:vidventure/pages/following_page.dart';
import 'package:vidventure/widgets/widgets.dart';

class DisplayPage extends StatefulWidget {
  final String username;
  final String uid;

  DisplayPage({Key? key, required this.username, required this.uid})
      : super(key: key);

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
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
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  void initState() {
    super.initState();
    _loadImages();
    _checkUserExistence();
    _getImages();
    _getFollowingCount();
    joinedorNot(widget.uid);
    _initBannerAd();
  }

  Future<void> _loadImages() async {
    final StorageService _storageService = StorageService(uid: widget.uid);
    List<String> imageUrls = await _storageService.listAllImages();
    setState(() {
      _imageUrls = imageUrls;
    });
  }

  Future<void> _getImages() async {
    final StorageService _storageService = StorageService(uid: widget.uid);
    List<String> imageUrls = await _storageService.listAllImages();
    setState(() {
      posts = imageUrls.length;
    });
  }

  Future<void> _checkUserExistence() async {
    int userExists = await DatabaseServices().getFollowersCount(widget.uid);
    setState(() {
      followers = userExists;
    });
  }

  Future<void> _getFollowingCount() async {
    int userExists = await DatabaseServices().getFollowingsCount(widget.uid);
    setState(() {
      following = userExists;
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

  joinedorNot(String groupId) {
    DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .isUserJoined(groupId)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.username,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildStatColumn("Followers", followers),
                buildStatColumn("Posts", posts),
                GestureDetector(
                  onTap: () {
                    nextScreen(context, FollowingPage(uid: widget.uid));
                  },
                  child: buildStatColumn("Following", following),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          buildFollowButton(),
          SizedBox(height: 15),
          Expanded(
            child: _imageUrls == null
                ? Center(child: CircularProgressIndicator())
                : buildImageGrid(),
          ),
        ],
      ),
      bottomNavigationBar: _isAdLoaded
          ? Container(
              height: _bannerAd.size.height.toDouble(),
              width: _bannerAd.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd),
            )
          : SizedBox(),
    );
  }

  Widget buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text("$count"),
      ],
    );
  }

  Widget buildFollowButton() {
    return InkWell(
      onTap: () async {
        await DatabaseServices(
          uid: FirebaseAuth.instance.currentUser!.uid,
        ).toggleGroupJoin(
          widget.uid,
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
          showSnackBar(
            context,
            Colors.green,
            "Successfully Following",
          );
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: isJoined
              ? LinearGradient(
                  colors: [
                    Colors.green.shade50,
                    Colors.green.shade200
                  ], // Green gradient for Following
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.purple.shade50
                  ], // Blue to purple gradient for Follow
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(color: Colors.white, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: Text(
            isJoined ? "Following" : "Follow",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget buildImageGrid() {
    return Padding(
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
    );
  }
}
