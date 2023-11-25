import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vidventure/auth/database_services.dart';
import 'package:vidventure/helper/helper_function.dart';
import 'package:vidventure/pages/display_page.dart';
import 'package:vidventure/pages/getfollowing_page.dart';
import 'package:vidventure/pages/home_page.dart';
import 'package:vidventure/pages/userprofile_page.dart';
import 'package:vidventure/widgets/widgets.dart';
// Import your DisplayPage class

class GetFollowersPage extends StatefulWidget {
  final String uid;

  GetFollowersPage({required this.uid});

  @override
  _GetFollowersPageState createState() => _GetFollowersPageState();
}

class _GetFollowersPageState extends State<GetFollowersPage> {
  late Future<List<DocumentSnapshot>> _followersInfo;

  @override
  void initState() {
    super.initState();
    _followersInfo = _getFollowersInfo();
    gettinguserdata();
  }

  Future<List<DocumentSnapshot>> _getFollowersInfo() async {
    DocumentSnapshot userSnapshot =
        await DatabaseServices(uid: widget.uid).getUserInfo(widget.uid);
    List<dynamic> followers = userSnapshot['followers'] ?? [];

    List<Future<DocumentSnapshot>> followersInfoFutures = [];
    for (var followerUid in followers) {
      followersInfoFutures.add(DatabaseServices().getUserInfo(followerUid));
    }

    List<DocumentSnapshot> followersInfo =
        await Future.wait(followersInfoFutures);
    return followersInfo;
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
        title: Text('Followers'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _followersInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No followers.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                int reversedIndex = snapshot.data!.length - 1 - index;
                var follower = snapshot.data![reversedIndex];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(follower['fullname']),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red,
                      child: Text(
                        follower['fullname'].substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayPage(
                            username: follower['fullname'],
                            uid: follower['uid'],
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
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              nextScreenReplacement(context, HomePage());
            },
            child: Container(
              child: Icon(Icons.home),
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
          Container(
            child: Icon(
              Icons.people,
              color: Colors.red,
            ),
          ),
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
}
