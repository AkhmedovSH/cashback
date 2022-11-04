import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: fz,
            ),
          ),
          Text(
            '$text2',
            style: TextStyle(
              fontSize: fz,
              fontWeight: FontWeight.w500,
            ),
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
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
              buildRow('sale_amount'.tr, formatMoney(cheque['totalAmount'] ?? 0)),
              buildRow('paid_in_soums'.tr, formatMoney(cheque['totalAmount'] != null ? cheque['totalAmount'] - cheque['writeOff'] : 0)),
              buildRow('paid_with_points'.tr, formatMoney(cheque['writeOff'])),
              buildRow('return_amount'.tr, formatMoney(cheque['returnAmount'])),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'status'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        cheque['status'] == 1 && cheque['returnStatus'] == 0
                            ? Text(
                                'confirmed'.tr,
                                style: TextStyle(fontSize: 16, color: success),
                              )
                            : const Text(''),
                        cheque['status'] == 2 && cheque['returnStatus'] == 0
                            ? Text(
                                'denied'.tr,
                                style: TextStyle(fontSize: 16, color: warning),
                              )
                            : const Text(''),
                        cheque['status'] == 3 && cheque['returnStatus'] == 0
                            ? Text(
                                'processing_error'.tr,
                                style: TextStyle(fontSize: 16, color: danger),
                              )
                            : const Text(''),
                        cheque['returnStatus'] == 1
                            ? Text(
                                'partially_returned'.tr,
                                style: TextStyle(fontSize: 16, color: warning),
                              )
                            : const Text(''),
                        cheque['returnStatus'] == 2
                            ? Text(
                                'fully_returned'.tr,
                                style: TextStyle(fontSize: 16, color: danger),
                              )
                            : const Text(''),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(left: 32),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: cheque['returnStatus'] != null && cheque['returnStatus'] < 2
              ? () {
                  showReturnModal(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: cheque['returnStatus'] != null && cheque['returnStatus'] < 2 ? purple : Colors.black.withOpacity(0.2),
          ),
          child: Text(
            'return'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
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
      } else {
        returnSetState(() {
          returnUser = {};
        });
        showErrorToast('Пользователь не найден');
        return false;
      }
    }
  }

  returnCheque() async {
    if (int.parse(data['returnAmount']) > 0) {
      final response = await post('/services/gocashapi/api/cashbox-return-cheque', data);
      if (response != null && response['success']) {
        showSuccessToast('successfully'.tr);
        Get.back();
        getCheq();
      }
    }
  }

  TextEditingController returnAmountCotroller = TextEditingController();

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
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: buildRow(
                        'sale_amount'.tr,
                        formatMoney(cheque['totalAmount'] ?? 0),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: buildRow(
                        'return_amount'.tr,
                        formatMoney(cheque['returnAmount']),
                      ),
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ThemeData().colorScheme.copyWith(
                              primary: purple,
                            ),
                      ),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                        ],
                        controller: returnAmountCotroller,
                        onChanged: (value) {
                          returnSetState(() {
                            if (value.isNotEmpty) {
                              if (int.parse(value) > (cheque['totalAmount'] - cheque['returnAmount']).round()) {
                                returnAmountCotroller.text = formatMoney(
                                  returnAmountCotroller.text.substring(
                                    0,
                                    returnAmountCotroller.text.length - 1,
                                  ),
                                );
                                returnAmountCotroller.selection = TextSelection.fromPosition(
                                  TextPosition(
                                    offset: returnAmountCotroller.text.length - 1,
                                  ),
                                );
                                return;
                              }
                              returnAmountCotroller.text = formatMoney(value);
                              returnAmountCotroller.selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: returnAmountCotroller.text.length - 1,
                                ),
                              );
                              data['returnAmount'] = value;
                            } else {
                              data['returnAmount'] = '0';
                            }
                          });
                        },
                        keyboardType: TextInputType.number,
                        cursorColor: purple,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.payments_outlined,
                          ),
                          contentPadding: const EdgeInsets.all(12.0),
                          focusColor: purple,
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
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.39,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: TextStyle(color: white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.39,
                      child: ElevatedButton(
                        onPressed: int.parse(data['returnAmount']) > 0
                            ? () {
                                returnCheque();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: int.parse(data['returnAmount']) > 0 ? purple : grey,
                          disabledBackgroundColor: Colors.black.withOpacity(0.2),
                        ),
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
        data = {'id': '', 'posId': '', 'cashierName': '', 'returnAmount': '0'};
      });
    }
  }
}
