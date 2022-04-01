import 'package:cashback/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:get/get.dart';

import 'package:new_version/new_version.dart';
import 'package:url_launcher/url_launcher.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  dynamic systemOverlayStyle = const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light);
  @override
  void initState() {
    super.initState();
    checkVersion();
    // startTimer();
  }

  void checkVersion() async {
    final newVersion = NewVersion(androidId: 'uz.cashbek.kassa');
    final status = await newVersion.getVersionStatus();
    print(status!.storeVersion);
    print(status.localVersion);
    if (status.storeVersion != '1.0.3') {
      setState(() {
        systemOverlayStyle = const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark);
      });
      await Navigator.of(context).push(RequiredUpdatePage(status.appStoreLink.toString()));
      SystemNavigator.pop();
      return;
    } else {
      startTimer();
    }
  }

  startTimer() {
    var _duration = const Duration(milliseconds: 2000);
    return Timer(_duration, navigate);
  }

  void navigate() async {
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    // bool lightMode =
    //     MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      backgroundColor: const Color(0xFF7D4196),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: systemOverlayStyle,
        elevation: 0,
      ),
      body: const Center(
          child: Text(
        'moneyBek',
        style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
      )),
    );
  }
}

class RequiredUpdatePage extends ModalRoute<void> {
  final String url;

  RequiredUpdatePage(this.url);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/cashback_icon.png',
                    height: 50,
                    // width: 50,
                  ),
                  Container(
                    child: Text(
                      'moneyBek',
                      style: TextStyle(color: purple, fontSize: 28, fontFamily: 'Lobster', fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                  'use_moneyBek_please_download_the_latest_version'.tr,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF7b8190), fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    onPressed: () {
                      launch(url);
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: Text(
                      'update_1'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    )),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
        Positioned(
            top: 10,
            right: 10,
            child: IconButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                icon: const Icon(
                  Icons.close,
                  size: 32,
                )))
      ],
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
