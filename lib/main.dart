import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'pages/index.dart';
import 'pages/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Init.instance.initialize(),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
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
            GetPage(name: '/splash', page: () => Splash()),
            GetPage(name: '/login', page: () => const Login()),
            GetPage(
                name: '/',
                page: () => const Index(),
                transition: Transition.fade)
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
      },
    );

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

class Splash extends StatefulWidget {
  Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  startTimer() {
    var _duration = Duration(milliseconds: 2000);
    return Timer(_duration, navigate);
  }

  void navigate() async {
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    bool lightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      backgroundColor:
          lightMode ? const Color(0xFF7D4196) : const Color(0xff042a49),
      body: Center(
          child: lightMode
              ? const Text(
                  'CASHBACK',
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )
              : Image.asset('assets/splash_dark.png')),
    );
  }
}

// class Splash extends StatelessWidget {
//   const Splash({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     bool lightMode =
//         MediaQuery.of(context).platformBrightness == Brightness.light;
//     return Scaffold(
//       backgroundColor:
//           lightMode ? const Color(0xFF7D4196) : const Color(0xff042a49),
//       body: Center(
//           child: lightMode
//               ? const Text(
//                   'CASHBACK',
//                   style: TextStyle(
//                       fontSize: 28,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold),
//                 )
//               : Image.asset('assets/splash_dark.png')),
//     );
//   }
// }

class Init {
  Init._();
  static final instance = Init._();

  Future initialize() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
