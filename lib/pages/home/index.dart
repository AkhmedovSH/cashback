import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashback/helpers/api.dart';
import 'package:cashback/helpers/helper.dart';
import 'package:cashback/helpers/product_controller.dart';

class Index extends StatefulWidget {
  dynamic products;
  final Function? clearProducts;
  final Function? showHideLoading;
  Index({Key? key, this.products, this.clearProducts, this.showHideLoading}) : super(key: key);

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  final focus = FocusNode();
  Timer? _debounce;
  final Controller productController = Get.put(Controller());
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
  dynamic previousValue = '';
  bool validate = true;

  debounce(value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      searchUser(value);
    });
  }

  searchUser(value) async {
    print(value.length);
    if (value.length == 6 || value.length == 12) {
      widget.showHideLoading!(true);
      final prefs = await SharedPreferences.getInstance();
      final response = await get('/services/gocashapi/api/cashbox-user-balance/${prefs.getString('posId')}/$value');
      print('res${response}');
      if (response['firstName'] != null) {
        setState(() {
          user = response;
        });
      } else {
        showErrorToast('Пользователь не найден');
      }
      widget.showHideLoading!(false);
    }
  }

  createCheque() async {
    if (user['firstName'] != null && validate && int.parse(data['writeOff'].text == '' ? '0' : data['writeOff'].text) > 0 ||
        int.parse(data['totalAmount'].text == '' ? '0' : data['totalAmount'].text) > 0) {
      widget.showHideLoading!(true);
      var sendData = Map.from(data);
      sendData['clientCode'] = data['clientCode'].text;
      sendData['totalAmount'] = data['totalAmount'].text == '' ? '0' : data['totalAmount'].text;
      sendData['writeOff'] = data['writeOff'].text == '' ? '0' : data['writeOff'].text;
      print(sendData);
      final response = await post('/services/gocashapi/api/cashbox-create-cheque', sendData);
      if (response['success']) {
        setState(() {
          data['clientCode'].text = '';
          data['totalAmount'].text = '';
          data['writeOff'].text = '';
          data['products'] = [];
          user = {};
        });
        widget.clearProducts!();
      }
      widget.showHideLoading!(false);
    }
  }

  deleteProduct(i) {
    dynamic productsCopy = widget.products;
    if (productsCopy.length == 1) {
      setState(() {
        widget.products = productsCopy.removeAt(i);
        data['products'] = [];
      });
      return;
    }
    productsCopy.removeAt(i);
    setState(() {
      widget.products = productsCopy;
    });
  }

  validateWriteOffField(value) {
    if (user['firstName'] != null) {
      if (data['writeOff'].text != '') {
        if (int.parse(data['writeOff'].text) > user['balance']) {
          setState(() {
            data['writeOff'].text = previousValue;
          });
        } else {
          setState(() {
            previousValue = value;
          });
        }
      }
    }
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = jsonDecode(prefs.getString('user')!);
    dynamic amount = 0;
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
    setState(() {
      data['products'] = widget.products;
    });
    print(widget.products);
    getData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ThemeData().colorScheme.copyWith(
                            primary: const Color(0xFF7D4196),
                          ),
                    ),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(focus);
                      },
                      controller: data['clientCode'],
                      onChanged: (value) {
                        debounce(value);
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.phone_iphone,
                        ),
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
                        hintText: 'qr_code_or_phone_number'.tr,
                        hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                      ),
                      style: const TextStyle(color: Color(0xFF9C9C9C)),
                    ),
                  )),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: user['firstName'] != null
                    ? Text(
                        '${user['firstName'] + ' ' + user['lastName']}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      )
                    : null,
              ),
              user['firstName'] != null
                  ? Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'balance'.tr + ': ',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            )),
                        Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              '${formatMoney(user['balance'])}',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: purple),
                            ))
                      ],
                    )
                  : Container(),
              Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ThemeData().colorScheme.copyWith(
                            primary: const Color(0xFF7D4196),
                          ),
                    ),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      focusNode: focus,
                      controller: data['totalAmount'],
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          validate = int.parse(data['totalAmount'].text == '' ? '0' : data['totalAmount'].text) > 0;
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
                        enabled: user['firstName'] != null,
                        fillColor: Colors.transparent,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                        ),
                        disabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7D4196)),
                        ),
                        hintText: 'payment_amount'.tr,
                        hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                      ),
                      style: const TextStyle(color: Color(0xFF9C9C9C)),
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ThemeData().colorScheme.copyWith(
                            primary: const Color(0xFF7D4196),
                          ),
                    ),
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      controller: data['writeOff'],
                      keyboardType: TextInputType.number,
                      scrollPadding: const EdgeInsets.only(bottom: 50),
                      onChanged: (value) {
                        // validateWriteOffField(value);
                        if (user['balance'] != null) {
                          setState(() {
                            validate = user['balance'] > int.parse(data['writeOff'].text == '' ? '0' : data['writeOff'].text);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.payments_outlined,
                        ),
                        enabled: user['firstName'] != null,
                        contentPadding: const EdgeInsets.all(18.0),
                        focusColor: const Color(0xFF7D4196),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                        ),
                        disabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7D4196)),
                        ),
                        hintText: 'accumulated_points'.tr,
                        hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                      ),
                      style: const TextStyle(color: Color(0xFF9C9C9C)),
                    ),
                  )),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('paid'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(
                        '${formatMoney(int.parse(data['totalAmount'].text != '' ? data['totalAmount'].text : '0') - int.parse(data['writeOff'].text != '' ? data['writeOff'].text : '0'))} So\'m',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('paid_with_points'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('${formatMoney(int.parse(data['writeOff'].text != '' ? data['writeOff'].text : '0'))} So\'m',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              for (var i = 0; i < data['products'].length; i++)
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
                          '${(i + 1)}' '. ' '${data['products'][i]['name']}',
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
                                  'barcode'.tr + ': ${data['products'][i]['barcode']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Text(
                              '${formatMoney(data['products'][i]['price'])} So\'m',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 80)
            ],
          ),
        ),
      )),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(left: 32),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: user['firstName'] != null && validate && int.parse(data['writeOff'].text == '' ? '0' : data['writeOff'].text) > 0 ||
                  int.parse(data['totalAmount'].text == '' ? '0' : data['totalAmount'].text) > 0
              ? () {
                  createCheque();
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            onSurface: Colors.black,
            primary: purple,
            // primary: user['firstName'] != null ? purple : grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'pay'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
    );
  }
}
