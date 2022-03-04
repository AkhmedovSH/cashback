import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    startTimer();
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
    return const Scaffold(
      backgroundColor: Color(0xFF7D4196),
      body: Center(
          child: Text(
        'moneyBek',
        style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
      )),
    );
  }
}
