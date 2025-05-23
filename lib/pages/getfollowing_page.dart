import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vidventure/auth/database_services.dart';
import 'package:vidventure/helper/helper_function.dart';
import 'package:vidventure/pages/discovery_page.dart';
import 'package:vidventure/pages/display_page.dart';
import 'package:vidventure/pages/getfollowers_page.dart';
import 'package:vidventure/pages/home_page.dart';
import 'package:vidventure/pages/userprofile_page.dart';
import 'package:vidventure/widgets/widgets.dart'; // Import your DisplayPage class

class GetFollowingPage extends StatefulWidget {
  final String uid;

  GetFollowingPage({required this.uid});

  @override
  _GetFollowingPageState createState() => _GetFollowingPageState();
}

class _GetFollowingPageState extends State<GetFollowingPage> {
  late Future<List<DocumentSnapshot>> _followingInfo;

  @override
  void initState() {
    super.initState();
    _followingInfo = _getFollowingInfo();
    gettinguserdata();
  }

  Future<List<DocumentSnapshot>> _getFollowingInfo() async {
    DocumentSnapshot userSnapshot =
        await DatabaseServices(uid: widget.uid).getUserInfo(widget.uid);
    List<dynamic> following = userSnapshot['following'] ?? [];

    List<Future<DocumentSnapshot>> followingInfoFutures = [];
    for (var followingUid in following) {
      followingInfoFutures.add(DatabaseServices().getUserInfo(followingUid));
    }

    List<DocumentSnapshot> followingInfo =
        await Future.wait(followingInfoFutures);
    return followingInfo;
  }

  String? username;
  gettinguserdata() async {
    await HelperFunctions.getUserNamelKey().then((value) {
      setState(() {
        username = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Following',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _followingInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Not following anyone.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                int reversedIndex = snapshot.data!.length - 1 - index;
                var followingUser = snapshot.data![reversedIndex];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(followingUser['fullname']),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red,
                      child: Text(
                        followingUser['fullname'].substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayPage(
                            username: followingUser['fullname'],
                            uid: followingUser['uid'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
            left: 16, right: 16, bottom: 16), // Adds spacing
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
              GestureDetector(
                onTap: () {
                  nextScreenReplacement(context, HomePage());
                },
                child: Icon(Icons.home),
              ),
              Icon(Icons.favorite, color: Colors.grey), // Highlighted icon
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
}
