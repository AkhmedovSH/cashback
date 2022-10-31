import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/translations.dart';

import 'package:cashback/helpers/helper.dart';

import 'pages/splash.dart';

import 'pages/auth/login.dart';
import 'pages/auth/select_access_pos.dart';

import 'pages/home/dashboard.dart';
import 'package:cashback/pages/home/qr_scanner.dart';
import 'pages/cheque_by_id.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final prefs = await SharedPreferences.getInstance();
  dynamic locale = const Locale('uz_latn', 'UZ');

  if (prefs.getString('currentLocale') != null) {
    if (prefs.getString('currentLocale') == '1') {
      locale = const Locale('ru', 'RU');
    }
    if (prefs.getString('currentLocale') == '3') {
      locale = const Locale('uz_latn', 'UZ');
    }
    if (prefs.getString('currentLocale') == '4') {
      locale = const Locale('uz_cyrl', 'UZ');
    }
  }

  runApp(GetMaterialApp(
    translations: Messages(),
    locale: locale,
    fallbackLocale: const Locale('uz_latn', 'UZ'),
    debugShowCheckedModeBanner: false,
    popGesture: true,
    defaultTransition: Transition.fade,
    // transitionDuration: Duration(milliseconds: 250),
    theme: ThemeData(
      backgroundColor: const Color(0xFFFFFFFF),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: purple,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        primary: purple,
      )),
    ),
    initialRoute: '/splash',
    getPages: [
      GetPage(name: '/splash', page: () => const Splash()),
      GetPage(name: '/login', page: () => const Login(), transition: Transition.fade),
      GetPage(name: '/select-access-pos', page: () => const SelectAccessPos(), transition: Transition.fade),
      GetPage(name: '/dashboard', page: () => const Dashboard(), transition: Transition.fade),
      GetPage(name: '/cheque-by-id', page: () => const ChequeById(), transition: Transition.fade),
      GetPage(name: '/qr-scanner', page: () => const QrScanner(), transition: Transition.fade),
    ],
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Messages(),
      locale: const Locale('uz_latn', 'UZ'),
      fallbackLocale: const Locale('ru', 'RU'),
      debugShowCheckedModeBanner: false,
      popGesture: true,
      defaultTransition: Transition.leftToRight,
      // transitionDuration: Duration(milliseconds: 250),
      theme: ThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: purple,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
          primary: purple,
        )),
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const Splash()),
        GetPage(name: '/login', page: () => const Login(), transition: Transition.fade),
        GetPage(name: '/select-access-pos', page: () => const SelectAccessPos(), transition: Transition.fade),

        GetPage(name: '/dashboard', page: () => const Dashboard(), transition: Transition.fade),

        GetPage(name: '/cheque-by-id', page: () => const ChequeById(), transition: Transition.fade),

        // GetPage(name: '/', page: () => const Index(), transition: Transition.fade),
        // GetPage(name: '/reports', page: () => const Reports(), transition: Transition.fade),
        // GetPage(name: '/checks', page: () => const Checks(), transition: Transition.fade),
      ],
    );
  }
}
