import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Index extends StatefulWidget {
  const Index({Key? key}) : super(key: key);

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          // color: Colors.white,
          margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
          // color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 95),
                child: Image.asset(
                  'images/cashback_icon.png',
                  height: 70,
                  width: 70,
                ),
              ),
              // Container(
              //   margin: const EdgeInsets.only(bottom: 40),
              //   child: const Text(
              //     'Войдите в систему чтобы продолжить',
              //     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              //   ),
              // ),
              Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ThemeData().colorScheme.copyWith(
                            primary: const Color(0xFF7D4196),
                          ),
                    ),
                    child: TextField(
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
                        hintText: 'QR Code или Телефон номер',
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
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.credit_card,
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
                        hintText: 'Сумма оплаты',
                        hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                      ),
                      style: const TextStyle(color: Color(0xFF9C9C9C)),
                    ),
                  )),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(left: 32),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Оплата прошла успешно'),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Посмотреть отчеты'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
                // actions: <Widget>[
                //   TextButton(
                //     onPressed: () => Navigator.pop(context, 'Cancel'),
                //     child: const Text('Cancel'),
                //   ),
                //   TextButton(
                //     onPressed: () => Navigator.pop(context, 'OK'),
                //     child: const Text('OK'),
                //   ),
                // ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Оплатить',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
    );
  }
}
