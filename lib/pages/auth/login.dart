import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/api.dart';
import '../../helpers/helper.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  dynamic sendData = {'username': 'cashier', 'password': '123123'};
  bool showPassword = true;
  List translations = [
    {'id': 1, 'name': 'Русский', 'locale': const Locale('ru', 'RU')},
    {'id': 3, 'name': 'Узбекский(лат)', 'locale': const Locale('uz_latn', 'UZ')},
    {'id': 4, 'name': 'Узбекский(кир)', 'locale': const Locale('uz_cyrl', 'UZ')},
  ];
  dynamic currentLocale = '1';

  login() async {
    final response = await guestPost('/auth/login', sendData);

    if (response['access_token'] != null) {
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
  }

  updateTranslation(newValue) {
    for (var i = 0; i < translations.length; i++) {
      if (translations[i]['id'].toString() == newValue) {
        Get.updateLocale(translations[i]['locale']);
      }
    }
    setState(() {
      currentLocale = newValue;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                    primary: const Color(0xFF7D4196),
                                  ),
                            ),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'required_field'.tr;
                                }
                                return null;
                              },
                              initialValue: sendData['username'],
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
                                    )),
                                contentPadding: const EdgeInsets.all(18.0),
                                focusColor: const Color(0xFF7D4196),
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF7D4196)),
                                ),
                                hintText: 'telephone_number'.tr + '(9* *** ** **)',
                                hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                              ),
                              style: const TextStyle(color: Color(0xFF9C9C9C)),
                            ),
                          )),
                      Container(
                          margin: const EdgeInsets.only(bottom: 25),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ThemeData().colorScheme.copyWith(
                                    primary: const Color(0xFF7D4196),
                                  ),
                            ),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'required_field'.tr;
                                }
                                return null;
                              },
                              initialValue: sendData['password'],
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
                                        ))
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
                                focusColor: const Color(0xFF7D4196),
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF7D4196)),
                                ),
                                hintText: 'Пароль',
                                hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                              ),
                              style: const TextStyle(color: Color(0xFF9C9C9C)),
                            ),
                          )),
                    ],
                  )),
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
            'login'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
    );
  }
}
