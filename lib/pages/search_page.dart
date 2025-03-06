import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vidventure/auth/database_services.dart';
import 'package:vidventure/pages/display_page.dart';
import 'package:vidventure/widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchcontroller = TextEditingController();
  bool _isloading = false;
  QuerySnapshot? searchSnapshot;
  bool hasusersearched = false;
  bool isJoined = false;
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initBannerAd();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
            child: Container(
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _searchcontroller,
                    decoration: InputDecoration(
                        hintText: "Search for people!....",
                        hintStyle: TextStyle(fontSize: 16),
                        border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () {
                        searchuser();
                      },
                      icon: Icon(Icons.search))
                ],
              ),
            ),
          ),
          _isloading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : users()
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

  users() {
    return hasusersearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  nextScreen(
                      context,
                      DisplayPage(
                          username: searchSnapshot!.docs[index]['fullname'],
                          uid: searchSnapshot!.docs[index]['uid']));
                },
                child: groupTile(searchSnapshot!.docs[index]['fullname'],
                    searchSnapshot!.docs[index]['uid']),
              );
            },
          )
        : Container();
  }

  searchuser() async {
    if (_searchcontroller.text.isNotEmpty) {
      setState(() {
        _isloading = true;
      });
      await DatabaseServices()
          .searchbyname(_searchcontroller.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          _isloading = false;
          hasusersearched = true;
        });
      });
    }
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

  groupTile(String userName, String groupId) {
    joinedorNot(groupId);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: Container(
        width: 60, // Diameter = 2 * radius
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50
            ], // Light gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            userName.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
      ),
      title: Text(
        "${userName}",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: InkWell(
          onTap: () async {
            await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
                .toggleGroupJoin(
              groupId,
            );
            if (isJoined) {
              setState(() {
                isJoined = !isJoined;
              });
              showSnackBar(context, Colors.green, "Successfully Following");
              Future.delayed(const Duration(seconds: 2), () {
                nextScreen(
                    context, DisplayPage(username: userName, uid: groupId));
              });
            } else {
              setState(() {
                isJoined = !isJoined;
              });
              showSnackBar(context, Colors.red, "Unfollowing");
            }
          },
          child: isJoined
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade50,
                        Colors.purple.shade50
                      ], // Light gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border:
                        Border.all(color: Colors.grey, width: 1), // Grey border
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text(
                    "Following",
                    style: TextStyle(
                        color: Colors.black), // Black text for contrast
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Colors.pink,
                        Colors.white,
                      ], // Stronger gradient for "Follow"
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text(
                    "Follow",
                    style: TextStyle(color: Colors.white),
                  ),
                )),
    );
  }
}
