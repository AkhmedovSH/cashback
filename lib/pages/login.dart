import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/api.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  dynamic sendData = {'username': 'testmd', 'password': '8520'};
  bool showPassword = true;

  login() async {
    final response = await guestPost('/auth/login', sendData);
    print(response);
    print(response['access_token'] != null);
    if (response['access_token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('access_token', response['access_token'].toString());
      Get.offAllNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          // color: Colors.white,
          margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
          // color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                margin: const EdgeInsets.only(bottom: 15),
                child: const Text(
                  'Добро пожаловать в CashBek',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: const Text(
                  'Войдите в систему чтобы продолжить',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
                                  return 'Обязательное поле';
                                }
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
                                hintText: 'Телефонный номер(9* *** ** **)',
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
                                  return 'Обязательное поле';
                                }
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
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(bottom: 50),
                child: const Text(
                  'Забыли пароль?',
                  style: TextStyle(color: Color(0xFF7D4196), fontWeight: FontWeight.bold, fontSize: 16),
                ),
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
          child: const Text(
            'Войти',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
    );
  }
}
