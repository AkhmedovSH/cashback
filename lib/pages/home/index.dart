import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashback/helpers/api.dart';
import 'package:cashback/helpers/helper.dart';

class Index extends StatefulWidget {
  final dynamic products;
  final Function? clearProducts;
  const Index({Key? key, this.products, this.clearProducts}) : super(key: key);

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  dynamic data = {
    'posId': '',
    'clientCode': TextEditingController(),
    'totalAmount': TextEditingController(),
    'writeOff': TextEditingController(),
    'cashierName': '',
    'products': []
  };
  dynamic user = {};
  dynamic totalAmount = 0;

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

  createCheque() async {
    if (user['firstName'] != null) {
      var sendData = Map.from(data);
      sendData['clientCode'] = data['clientCode'].text;
      sendData['totalAmount'] = data['totalAmount'].text == '' ? '0' : data['totalAmount'].text;
      sendData['writeOff'] = data['writeOff'].text == '' ? '0' : data['writeOff'].text;
      final response = await post('/services/gocashapi/api/cashbox-create-cheque', sendData);
      print(response);
      if (response['success']) {
        setState(() {
          data['clientCode'].text = '';
          data['totalAmount'].text = '';
          data['writeOff'].text = '';
          data['products'] = [];
        });
        widget.clearProducts!();
      }
    }
  }

  deleteProduct(i) {
    dynamic productsCopy = widget.products;
    productsCopy.removeAt(i);
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = jsonDecode(prefs.getString('user')!);
    print(widget.products);
    dynamic amount = 0;
    for (var i = 0; i < widget.products.length; i++) {
      amount = widget.products[i]['quantity'] * widget.products[i]['amount'];
    }
    setState(() {
      data['posId'] = prefs.getString('posId');
      data['cashierName'] = user['username'];
      data['products'] = widget.products;
      totalAmount = amount;
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
                      controller: data['clientCode'],
                      onChanged: (value) {
                        searchUser(value);
                      },
                      keyboardType: TextInputType.number,
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
                      controller: data['totalAmount'],
                      keyboardType: TextInputType.number,
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
                      controller: data['writeOff'],
                      keyboardType: TextInputType.number,
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
              for (var i = 0; i < widget.products.length; i++)
                Dismissible(
                  key: UniqueKey(),
                  onDismissed: (DismissDirection direction) {
                    deleteProduct(i);
                  },
                  background: Container(
                    color: white,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 10, bottom: 10, top: 10),
                    child: Icon(Icons.delete, color: red),
                  ),
                  direction: DismissDirection.endToStart,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF5F3F5), width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(i + 1).toString() + '. ' + widget.products[i]['name']}',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Text(
                                  '${formatMoney(widget.products[i]['amount'])}x ${formatMoney(widget.products[i]['quantity'])}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Text(
                              '${formatMoney(int.parse(widget.products[i]['quantity']) * int.parse(widget.products[i]['amount']))}So\'m',
                              style: TextStyle(fontWeight: FontWeight.w600, color: purple, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
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
            // primary: user['firstName'] != null && (user['balance']).round() > int.parse(data['writeOff']) && int.parse(data['writeOff']) > 0 ||
            //         int.parse(data['totalAmount']) > 0
            primary: user['firstName'] != null ? purple : grey,
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
