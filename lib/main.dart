import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/index.dart';
import 'pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      popGesture: true,
      defaultTransition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 250),
      theme: ThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF7D4196),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
          primary: const Color(0xFF7D4196),
        )),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const Login()),
        GetPage(
            name: '/', page: () => const Index(), transition: Transition.fade)
      ],
    );
  }
}
