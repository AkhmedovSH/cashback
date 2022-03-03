import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashback/helpers/api.dart';
import 'package:cashback/helpers/helper.dart';

class ChequeById extends StatefulWidget {
  const ChequeById({Key? key}) : super(key: key);

  @override
  State<ChequeById> createState() => _ChequeByIdState();
}

class _ChequeByIdState extends State<ChequeById> {
  dynamic showReturnDialog = false;
  dynamic cheque = {};
  dynamic products = [];
  dynamic data = {'id': '', 'posId': '', 'clientCode': '', 'cashierName': '', 'returnAmount': '0'};
  dynamic user = {};

  searchUser(value) async {
    if (value.length == 6 || value.length == 12) {
      final prefs = await SharedPreferences.getInstance();
      final response = await get('/services/gocashapi/api/cashbox-user-balance/${prefs.getString('posId')}/$value');
      if (response['firstName']! != null) {
        setState(() {
          user = response;
        });
      }
    }
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    final cashier = jsonDecode(prefs.getString('user')!);
    setState(() {
      data['id'] = cheque['id'].toString();
      data['posId'] = prefs.getString('posId');
      data['cashierName'] = cashier['username'];
    });
  }

  returnCheque() async {
    // print(data);
    if (user['firstName'] != null) {
      final response = await post('/services/gocashapi/api/cashbox-return-cheque', data);
      print(response);
      Navigator.pop(context);
      Get.back();
    }
  }

  @override
  void initState() {
    super.initState();
    getCheq();
  }

  getCheq() async {
    final response = await get('/services/gocashapi/api/cashbox-cheque/${Get.arguments}');
    setState(() {
      cheque = response;
      products = response['products'];
    });
  }

  buildRow(text, text2, {fz = 16.0}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: fz),
        ),
        Text(
          '$text2',
          style: TextStyle(fontSize: fz),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ))),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Center(
                  child: Image.asset(
                'images/cashback_logo.png',
                height: 64,
                width: 200,
              )),
              buildRow('Кассир', cheque['cashierName']),
              buildRow('№ чека', cheque['id']),
              buildRow('Дата', cheque['chequeDate'] != null ? formatDate(cheque['chequeDate']) : ''),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: const Text(
                  '*****************************************************************************************',
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              Table(columnWidths: const {
                0: FlexColumnWidth(5),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(3),
              }, children: [
                TableRow(children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: const Text('№ Товар', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: const Text('Кол-во', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: const Text('Цена', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ]),
                for (var i = 0; i < products.length; i++)
                  TableRow(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${i + 1} ${products[i]['name']}',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${formatMoney(products[i]['quantity'])}',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${formatMoney(products[i]['amount'])}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ])
              ]),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: const Text(
                  '*****************************************************************************************',
                  style: TextStyle(),
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              buildRow('Сумма продажи', formatMoney(cheque['totalAmount'])),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(left: 32),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            showReturnModal(context);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Возврат',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
    );
  }

  showReturnModal(context) {
    getData();
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        // titlePadding: EdgeInsets.all(0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        title: const Text(
          'Возврат',
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
          child: Column(
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
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone_iphone,
                        ),
                        contentPadding: EdgeInsets.all(12.0),
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
                          data['returnAmount'] = value;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                        ),
                        contentPadding: EdgeInsets.all(12.0),
                        focusColor: Color(0xFF7D4196),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7D4196)),
                        ),
                        hintText: 'Сумма возврата',
                        hintStyle: TextStyle(color: Color(0xFF9C9C9C)),
                      ),
                      style: const TextStyle(color: Color(0xFF9C9C9C)),
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    primary: white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(side: BorderSide(color: red, width: 1), borderRadius: BorderRadius.circular(5)),
                  ),
                  child: Text(
                    'Отмена',
                    style: TextStyle(color: red),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: ElevatedButton(
                  onPressed: () {
                    returnCheque();
                    // Get.back();
                  },
                  style:
                      ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), primary: user['firstName'] != null ? purple : grey),
                  child: const Text('Продолжить'),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
