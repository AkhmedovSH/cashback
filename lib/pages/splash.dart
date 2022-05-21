import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:get/get.dart';

import 'package:new_version/new_version.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashback/helpers/helper.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  dynamic systemOverlayStyle = const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light);
  dynamic vesrion = '';
  dynamic url = '';
  bool isRequired = false;

  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  void checkVersion() async {
    final newVersion = NewVersion(androidId: 'uz.cashbek.kassa');
    dynamic status;
    try {
      status = await newVersion.getVersionStatus();
      setState(() {
        vesrion = status!.localVersion;
        url = status.appStoreLink.toString();
      });
      if (status!.storeVersion != status.localVersion) {
        final prefs = await SharedPreferences.getInstance();

        final lastVersion = status.storeVersion.split('.')[2];
        if ((int.parse(lastVersion) % 3).round() == 0) {
          setState(() {
            isRequired = true;
          });
        }
        await showUpdateDialog();
        if (isRequired) {
          SystemNavigator.pop();
          prefs.remove('lastShow');
        } else {
          startTimer();
          prefs.setString('lastShow', jsonEncode({'storeVersion': status.storeVersion, 'time': DateTime.now().millisecondsSinceEpoch.toString()}));
        }

        return;
      } else {
        startTimer();
      }
    } catch (e) {
      checkVersion();
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
    return Scaffold(
      backgroundColor: purple,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: systemOverlayStyle,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
              child: Text(
            'moneyBek',
            style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
          )),
          const SizedBox(
            height: 5,
          ),
          Center(
            child: Text(
              vesrion,
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  showUpdateDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              insetPadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
              title: Text(
                'update_app'.tr + '"moneyBek"',
                style: const TextStyle(color: Colors.black),
              ),
              scrollable: true,
              content: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRequired
                          ? 'we_recommend_installing_the_latest_version_of_the_application'.tr + '"moneyBek".'
                          : 'we_recommend_installing_the_latest_version_of_the_application'.tr +
                              '"moneyBek".' +
                              'while_downloading_updates_you_can_still_use_it'.tr +
                              '.',
                      style: const TextStyle(color: Colors.black, height: 1.2),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          isRequired
                              ? Container()
                              : Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    style: TextButton.styleFrom(primary: const Color(0xFF00865F)),
                                    child: Text(
                                      'no_thanks'.tr,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                          ElevatedButton(
                            onPressed: () {
                              launch(url);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: const Color(0xFF00865F),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 0,
                            ),
                            child: Text('update'.tr),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Image.asset(
                        'images/google_play.png',
                        height: 25,
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }
}
