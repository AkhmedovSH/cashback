import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashback/helpers/api.dart';
import 'package:cashback/helpers/helper.dart';

class Index extends StatefulWidget {
  const Index({Key? key}) : super(key: key);

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool showCreateProductDialog = false;
  bool showProductsDialog = false;
  dynamic data = {'posId': '', 'clientCode': '', 'totalAmount': '', 'writeOff': '', 'cashierName': ''};

  searchUser(value) async {
    if (value.length == 6 || value.length == 12) {
      final prefs = await SharedPreferences.getInstance();
      final response = await get('/services/gocashapi/api/cashbox-user-balance/${prefs.getString('posId')}/$value');
      print(response);
    }
  }

  createCheque() async {
    final response = await post('/services/gocashapi/api/cashbox-create-cheque', data);
    print(response);
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = jsonDecode(prefs.getString('user')!);
    setState(() {
      data['posId'] = prefs.getString('posId');
      data['cashierName'] = user['username'];
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ThemeData().colorScheme.copyWith(
                            primary: const Color(0xFF7D4196),
                          ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          data['clientCode'] = value;
                        });
                        searchUser(value);
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone_iphone,
                        ),
                        contentPadding: EdgeInsets.all(18.0),
                        focusColor: Color(0xFF7D4196),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7D4196)),
                        ),
                        hintText: 'QR Code или Телефон номер',
                        hintStyle: TextStyle(color: Color(0xFF9C9C9C)),
                      ),
                      style: const TextStyle(color: Color(0xFF9C9C9C)),
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ThemeData().colorScheme.copyWith(
                            primary: const Color(0xFF7D4196),
                          ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          data['totalAmount'] = value;
                        });
                      },
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
              Container(
                  margin: const EdgeInsets.only(bottom: 90),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ThemeData().colorScheme.copyWith(
                            primary: const Color(0xFF7D4196),
                          ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          data['writeOff'] = value;
                        });
                      },
                      scrollPadding: const EdgeInsets.only(bottom: 50),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                        ),
                        contentPadding: EdgeInsets.all(18.0),
                        focusColor: Color(0xFF7D4196),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7D4196)),
                        ),
                        hintText: 'Накопленные баллы',
                        hintStyle: TextStyle(color: Color(0xFF9C9C9C)),
                      ),
                      style: const TextStyle(color: Color(0xFF9C9C9C)),
                    ),
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
            createCheque();
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
