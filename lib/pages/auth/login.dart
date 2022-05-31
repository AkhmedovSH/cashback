import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app_settings/app_settings.dart';

import '../../helpers/api.dart';
import '../../helpers/helper.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  static dynamic auth = LocalAuthentication();
  final _formKey = GlobalKey<FormState>();
  AnimationController? animationController;
  dynamic sendData = {
    'username': '',
    'password': '',
    'isRemember': false,
    'signWithFingerPrint': false,
  }; //
  dynamic data = {
    'username': TextEditingController(),
    'password': TextEditingController(),
    'isRemember': false,
    'signWithFingerPrint': false,
  }; // cashier 123123
  bool showPassword = true;
  bool loading = false;
  List translations = [
    {'id': 3, 'name': 'Узбекский(лат)', 'locale': const Locale('uz_latn', 'UZ')},
    {'id': 1, 'name': 'Русский', 'locale': const Locale('ru', 'RU')},
    {'id': 4, 'name': 'Узбекский(кир)', 'locale': const Locale('uz_cyrl', 'UZ')},
  ];
  dynamic currentLocale = '3';

  login() async {
    setState(() {
      loading = true;
    });
    final response = await guestPost('/auth/login', sendData);
    if (response != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('access_token', response['access_token'].toString());
      prefs.setString('user', jsonEncode(sendData));
      final user = await get('/services/uaa/api/account');
      
      for (var i = 0; i < user['authorities'].length; i++) {
        if (user['authorities'][i] == 'ROLE_CASHIER') {
          Get.offAllNamed('/select-access-pos');
        }
      }
    }
    setState(() {
      loading = false;
    });
  }

  updateTranslation(newValue) async {
    final prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < translations.length; i++) {
      if (translations[i]['id'].toString() == newValue) {
        Get.updateLocale(translations[i]['locale']);
      }
    }
    setState(() {
      prefs.setString('currentLocale', newValue);
      currentLocale = newValue;
    });
  }

  changeRemember(value) async {
    final isDeviceSupported = await auth.isDeviceSupported();
    if (!isDeviceSupported) {
      AppSettings.openSecuritySettings();
      return;
    }
    setState(() {
      sendData['signWithFingerPrint'] = value;
    });
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      final user = jsonDecode(prefs.getString('user')!);
      setState(() {
        user['signWithFingerPrint'] = sendData['signWithFingerPrint'];
      });
      prefs.setString('user', jsonEncode(user));
    }
  }

  static Future<bool> hasBiometrics() async {
    try {
      return await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      return false;
    }
  }

  getFingerprint() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      final user = jsonDecode(prefs.getString('user')!);
      setState(() {
        sendData['signWithFingerPrint'] = user['signWithFingerPrint'];
      });
    }
    if (prefs.getString('access_token') != null && sendData['signWithFingerPrint']) {
      final isAvailable = await hasBiometrics();
      if (!isAvailable) return false;
      try {
        final result = await auth.authenticate(
            localizedReason: 'scan_your_fingerprint_for_authentication'.tr,
            options: const AuthenticationOptions(
              useErrorDialogs: true,
              stickyAuth: true,
            ),
            authMessages: <AuthMessages>[
              AndroidAuthMessages(
                signInTitle: 'sign_in_with_your_fingerprint'.tr,
                cancelButton: 'use_another_way'.tr + '...',
                goToSettingsButton: '',
                biometricHint: '',
              ),
              IOSAuthMessages(
                lockOut: 'test',
                cancelButton: 'use_another_way'.tr + '...',
              ),
            ]);
        if (result && prefs.getString('user') != null) {
          setState(() {
            loading = true;
          });
          final user = jsonDecode(prefs.getString('user')!);
          final response = await guestPost('/auth/login', user);
          prefs.setString('access_token', response['access_token'].toString());
          var account = await get('/services/uaa/api/account');
          var checkAccess = false;
          for (var i = 0; i < account['authorities'].length; i++) {
            if (account['authorities'][i] == 'ROLE_CASHIER') {
              checkAccess = true;
            }
          }
          setState(() {
            loading = false;
          });
          if (checkAccess) {
            Get.offAllNamed('/dashboard');
          } else {
            // у вас нету доступа
          }
        }
      } on PlatformException catch (e) {
        return false;
      }
    }
  }

  checkIsRemember() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      final user = jsonDecode(prefs.getString('user')!);
      if (user['isRemember']) {
        setState(() {
          sendData['isRemember'] = user['isRemember'];
          sendData['username'] = user['username'];
          sendData['password'] = user['password'];
          data['username'].text = user['username'];
          data['password'].text = user['password'];
        });
      }
    }
  }

  getCurrentLocale() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('currentLocale') != null) {
      updateTranslation(prefs.getString('currentLocale'));
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    });
    getFingerprint();
    getCurrentLocale();
    checkIsRemember();
  }

  @override
  dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
              child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Image.asset(
                          'images/cashback_icon.png',
                          height: 70,
                          width: 70,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.44,
                        height: 50,
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 2, color: Color(0xFFECECEC)))),
                        // decoration: const ShapeDecoration(
                        //   shape: RoundedRectangleBorder(
                        //     side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Color(0xFFECECEC)),
                        //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        //   ),
                        // ),
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton(
                              value: currentLocale,
                              isExpanded: true,
                              hint: Text('${translations[0]['name']}'),
                              icon: const Icon(Icons.chevron_right),
                              iconSize: 24,
                              iconEnabledColor: purple,
                              elevation: 16,
                              style: const TextStyle(color: Color(0xFF313131)),
                              underline: Container(
                                height: 2,
                                width: MediaQuery.of(context).size.width * 0.44,
                                color: purple,
                              ),
                              onChanged: (newValue) {
                                updateTranslation(newValue);
                              },
                              items: translations.map((item) {
                                return DropdownMenuItem<String>(
                                  value: '${item['id']}',
                                  child: Text(item['name']),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'welcome_to_moneyback'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Text(
                      'sign_in_to_continue'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ThemeData().colorScheme.copyWith(
                                    primary: purple,
                                  ),
                            ),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'required_field'.tr;
                                }
                                return null;
                              },
                              controller: data['username'],
                              onChanged: (value) {
                                setState(() {
                                  sendData['username'] = value;
                                });
                              },
                              decoration: InputDecoration(
                                prefixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.phone_iphone,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(18.0),
                                focusColor: purple,
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF7D4196)),
                                ),
                                hintText: 'login'.tr,
                                hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                              ),
                              style: const TextStyle(color: Color(0xFF9C9C9C)),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ThemeData().colorScheme.copyWith(
                                    primary: purple,
                                  ),
                            ),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'required_field'.tr;
                                }
                                return null;
                              },
                              controller: data['password'],
                              onChanged: (value) {
                                setState(() {
                                  sendData['password'] = value;
                                });
                              },
                              obscureText: showPassword,
                              decoration: InputDecoration(
                                prefixIcon: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.lock,
                                    )),
                                suffixIcon: showPassword
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showPassword = false;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.visibility_off,
                                          // color: Color(0xFF7D4196),
                                        ),
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showPassword = true;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.visibility,
                                          // color: Color(0xFF7D4196),
                                        )),
                                contentPadding: const EdgeInsets.all(18.0),
                                focusColor: purple,
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF7D4196)),
                                ),
                                hintText: 'password'.tr,
                                hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                              ),
                              style: const TextStyle(color: Color(0xFF9C9C9C)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'remember_me'.tr,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Switch(
                        value: sendData['isRemember'],
                        activeColor: purple,
                        onChanged: (bool value) {
                          setState(() {
                            sendData['isRemember'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'login_with_fingerprint'.tr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Switch(
                        value: sendData['signWithFingerPrint'],
                        activeColor: purple,
                        onChanged: (bool value) {
                          changeRemember(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
          floatingActionButton: Container(
            margin: const EdgeInsets.only(left: 32),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  login();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'enter'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ),
        ),
        loading
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.4),
                child: SpinKitThreeBounce(
                  color: purple,
                  size: 35.0,
                  controller: animationController,
                ),
              )
            : Container()
      ],
    );
  }
}
