import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'helpers/translations.dart';

import 'pages/splash.dart';

import 'pages/auth/login.dart';
import 'pages/auth/select_access_pos.dart';

import 'pages/home/dashboard.dart';

import 'pages/cheque_by_id.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Messages(),
      locale: const Locale('ru', 'RU'),
      fallbackLocale: const Locale('en', 'EN'),
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

        GetPage(name: '/dashboard', page: () => const Dashboard(), transition: Transition.fade),

        GetPage(name: '/cheque-by-id', page: () => const ChequeById(), transition: Transition.fade),

        // GetPage(name: '/', page: () => const Index(), transition: Transition.fade),
        // GetPage(name: '/reports', page: () => const Reports(), transition: Transition.fade),
        // GetPage(name: '/checks', page: () => const Checks(), transition: Transition.fade),
      ],
    );
  }
}
