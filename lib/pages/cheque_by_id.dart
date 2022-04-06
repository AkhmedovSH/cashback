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

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    final cashier = jsonDecode(prefs.getString('user')!);
    setState(() {
      data['id'] = cheque['id'].toString();
      data['posId'] = prefs.getString('posId');
      data['cashierName'] = cashier['username'];
    });
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
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
      ),
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
              // Center(
              //     child: Image.asset(
              //   'images/cashback_icon.png',
              //   height: 64,
              //   width: 200,
              // )),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Center(
                  child: Text(
                    cheque['posName'] ?? '',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              buildRow('cashier'.tr, cheque['cashierName']),
              buildRow('№' + 'check'.tr, cheque['id']),
              buildRow('date'.tr, cheque['chequeDate'] != null ? formatDate(cheque['chequeDate']) : ''),
              buildRow('client'.tr, cheque['clientName']),
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
                    child: Text('№' + 'product'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('qty'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('price'.tr, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        '${formatMoney(products[i]['quantity']) + ' x ' + formatMoney(products[i]['price'])}',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${formatMoney(products[i]['price'] * products[i]['quantity'])}',
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
              buildRow('sale_amount'.tr, formatMoney(cheque['totalAmount'] != null ? cheque['totalAmount'] + cheque['writeOff'] : 0)),
              buildRow('paid_in_soums'.tr, formatMoney(cheque['totalAmount'])),
              buildRow('paid_with_points'.tr, formatMoney(cheque['writeOff'])),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'status'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    cheque['status'] == 1
                        ? Text(
                            'confirmed'.tr,
                            style: TextStyle(fontSize: 16, color: success),
                          )
                        : const Text(''),
                    cheque['status'] == 2
                        ? Text(
                            'denied'.tr,
                            style: TextStyle(fontSize: 16, color: warning),
                          )
                        : const Text(''),
                    cheque['status'] == 3
                        ? Text(
                            'processing_error'.tr,
                            style: TextStyle(fontSize: 16, color: danger),
                          )
                        : const Text(''),
                  ],
                ),
              )
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
          child: Text(
            'return'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
    );
  }

  dynamic returnUser = {};

  searchUser(value, returnSetState) async {
    if (value.length == 6 || value.length == 12) {
      final prefs = await SharedPreferences.getInstance();
      final response = await get('/services/gocashapi/api/cashbox-user-balance/${prefs.getString('posId')}/$value');
      if (response['id'] != null) {
        returnSetState(() {
          response['lastName'] = response['lastName'] ?? '';
          response['firstName'] = response['firstName'] ?? '';
          returnUser = response;
        });
      }
    }
  }

  returnCheque() async {
    if (returnUser['id'] != null && int.parse(data['returnAmount']) > 0) {
      final response = await post('/services/gocashapi/api/cashbox-return-cheque', data);
      if (response['success']) {
        showSuccessToast('successfully'.tr);
        Get.back();
        getCheq();
      }
    }
  }

  showReturnModal(context) async {
    getData();
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, returnSetState) {
            return AlertDialog(
              // titlePadding: EdgeInsets.all(0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              insetPadding: const EdgeInsets.symmetric(horizontal: 15),
              title: Text(
                'return'.tr,
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
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
                          child: TextField(
                            onChanged: (value) {
                              returnSetState(() {
                                data['clientCode'] = value;
                              });
                              searchUser(value, returnSetState);
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.phone_iphone,
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
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
                      child: returnUser['firstName'] != null
                          ? Text(
                              '${returnUser['firstName'] + ' ' + returnUser['lastName']}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            )
                          : null,
                    ),
                    returnUser['firstName'] != null
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
                                    '${formatMoney(returnUser['balance'])}',
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
                          child: TextField(
                            onChanged: (value) {
                              returnSetState(() {
                                if (value.isNotEmpty) {
                                  data['returnAmount'] = value;
                                } else {
                                  data['returnAmount'] = '0';
                                }
                              });
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.payments_outlined,
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                              focusColor: const Color(0xFF7D4196),
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF9C9C9C)),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF7D4196)),
                              ),
                              hintText: 'return_amount'.tr,
                              hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
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
                          primary: red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: TextStyle(color: white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: ElevatedButton(
                        onPressed: returnUser['firstName'] != null && int.parse(data['returnAmount']) > 0
                            ? () {
                                returnCheque();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            primary: returnUser['id'] != null ? purple : grey,
                            onSurface: Colors.black),
                        child: Text('proceed'.tr),
                      ),
                    )
                  ],
                )
              ],
            );
          });
        });
    if (result == null) {
      setState(() {
        returnUser = {};
        data = {'id': '', 'posId': '', 'clientCode': '', 'cashierName': '', 'returnAmount': '0'};
      });
    }
  }
}
