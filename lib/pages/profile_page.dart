import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vidventure/auth/auth_services.dart';
import 'package:vidventure/pages/home_page.dart';
import 'package:vidventure/widgets/widgets.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  String username;
  String email;
  ProfilePage({super.key, required this.username, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthServices authService = AuthServices();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
              widget.username,
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
              onTap: () {
                nextScreen(context, HomePage());
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group),
              title: Text(
                "Home",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            ListTile(
              onTap: () {},
              selected: true,
              selectedColor: Theme.of(context).primaryColor,
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
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.account_circle,
                size: 200,
                color: Colors.grey[700],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Full Name",
                    style: TextStyle(fontSize: 17),
                  ),
                  Text(
                    widget.username,
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Email",
                    style: TextStyle(fontSize: 17),
                  ),
                  Text(
                    widget.email,
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ],
          ),
        ),
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
}
