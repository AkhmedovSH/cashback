import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'pages/splash.dart';

import 'pages/auth/login.dart';
import 'pages/auth/selectAccessPos.dart';

import 'pages/home/index.dart';
import 'pages/home/reports.dart';
import 'pages/home/checks.dart';
import 'pages/home/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      popGesture: true,
      defaultTransition: Transition.leftToRight,
      // transitionDuration: Duration(milliseconds: 250),
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
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const Splash()),
        GetPage(name: '/login', page: () => const Login(), transition: Transition.fade),
        GetPage(name: '/select-access-pos', page: () => const SelectAccessPos(), transition: Transition.fade),

        GetPage(name: '/', page: () => const Index(), transition: Transition.fade),
        GetPage(name: '/reports', page: () => const Reports(), transition: Transition.fade),
        GetPage(name: '/checks', page: () => const Checks(), transition: Transition.fade),

        GetPage(name: '/dashboard', page: () => const Dashboard(), transition: Transition.fade),
      ],
    );
    // if (snapshot.connectionState == ConnectionState.waiting) {
    //   return const MaterialApp(home: Splash());
    // } else {
    //   return GetMaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     popGesture: true,
    //     defaultTransition: Transition.leftToRight,
    //     transitionDuration: Duration(milliseconds: 250),
    //     theme: ThemeData(
    //       backgroundColor: const Color(0xFFFFFFFF),
    //       scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    //       elevatedButtonTheme: ElevatedButtonThemeData(
    //         style: ElevatedButton.styleFrom(
    //           primary: const Color(0xFF7D4196),
    //         ),
    //       ),
    //       textButtonTheme: TextButtonThemeData(
    //           style: TextButton.styleFrom(
    //         primary: const Color(0xFF7D4196),
    //       )),
    //     ),
    //     initialRoute: '/splash',
    //     getPages: [
    //       GetPage(name: '/login', page: () => const Login()),
    //       GetPage(
    //           name: '/',
    //           page: () => const Index(),
    //           transition: Transition.fade)
    //     ],
    //   );
    // }

    // return GetMaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   popGesture: true,
    //   defaultTransition: Transition.leftToRight,
    //   transitionDuration: Duration(milliseconds: 250),
    //   theme: ThemeData(
    //     backgroundColor: const Color(0xFFFFFFFF),
    //     scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    //     elevatedButtonTheme: ElevatedButtonThemeData(
    //       style: ElevatedButton.styleFrom(
    //         primary: const Color(0xFF7D4196),
    //       ),
    //     ),
    //     textButtonTheme: TextButtonThemeData(
    //         style: TextButton.styleFrom(
    //       primary: const Color(0xFF7D4196),
    //     )),
    //   ),
    //   initialRoute: '/login',
    //   getPages: [
    //     GetPage(name: '/login', page: () => const Login()),
    //     GetPage(
    //         name: '/', page: () => const Index(), transition: Transition.fade)
    //   ],
    // );
  }
}
