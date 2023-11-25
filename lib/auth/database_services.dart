import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseServices {
  final String? uid;
  DatabaseServices({this.uid});

  final CollectionReference usercollection =
      FirebaseFirestore.instance.collection("users");

  Future savinguserdata(String fullname, String email) async {
    return await usercollection.doc(uid).set({
      "fullname": fullname,
      "email": email,
      "profilepic": "",
      "uid": uid,
      "following": [],
      "followers": [],
    });
  }

  Future gettinguserdata(String email) async {
    QuerySnapshot snapshot =
        await usercollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  Future<String?> path() async {
    return "users/${uid}/profilepic";
  }

  searchbyname(String groupName) {
    return usercollection.where("fullname", isEqualTo: groupName).get();
  }

  Future<bool> isuserfollowing(String followingsid) async {
    DocumentReference userdocumenrefernce = usercollection.doc(uid);
    DocumentSnapshot userdocumensnapshot = await userdocumenrefernce.get();
    List<dynamic> following = userdocumensnapshot["following"];
    if (following.contains(followingsid)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isUserJoined(String followingsid) async {
    DocumentReference userDocumentReference = usercollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot["following"];
    if (groups.contains("${followingsid}")) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> getFollowersCount(String userId) async {
    DocumentSnapshot userSnapshot = await usercollection.doc(userId).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      List<dynamic> followers = userData['followers'];
      int followersCount = followers.length;
      return followersCount;
    } else {
      // User document does not exist
      return 0;
    }
  }

  Future<DocumentSnapshot> getUserInfo(String uid) async {
    DocumentSnapshot userSnapshot = await usercollection.doc(uid).get();
    return userSnapshot;
  }

  Future<bool> isUserExist(String username) async {
    QuerySnapshot querySnapshot = await usercollection
        .where("fullname", isEqualTo: username.toLowerCase())
        .get();
    return querySnapshot.docs.isNotEmpty;
    /*if(querysnaphot.docs.isNotEmpty){return true}else{false} */
  }

  Future<int> getFollowingsCount(String userId) async {
    DocumentSnapshot userSnapshot = await usercollection.doc(userId).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      List<dynamic> following = userData['following'];
      int followingCount = following.length;
      return followingCount;
    } else {
      // User document does not exist
      return 0;
    }
  }

  Future toggleGroupJoin(String followingsid) async {
    // doc reference
    DocumentReference userDocumentReference = usercollection.doc(uid);
    DocumentReference groupDocumentReference = usercollection.doc(followingsid);

    // Get current user's following list and group's followers list
    DocumentSnapshot userSnapshot = await userDocumentReference.get();
    DocumentSnapshot groupSnapshot = await groupDocumentReference.get();

    // Get arrays from snapshots
    List<dynamic> userFollowing = userSnapshot['following'] ?? [];
    List<dynamic> groupFollowers = groupSnapshot['followers'] ?? [];

    // Check if user is already following the group
    bool isFollowing = userFollowing.contains(followingsid);

    // Update arrays based on user's current following status
    if (isFollowing) {
      userFollowing.remove(followingsid);
      groupFollowers.remove(uid);
    } else {
      userFollowing.add(followingsid);
      groupFollowers.add(uid);
    }

    // Update Firestore documents with modified arrays
    await userDocumentReference.update({"following": userFollowing});
    await groupDocumentReference.update({"followers": groupFollowers});
  }
}
