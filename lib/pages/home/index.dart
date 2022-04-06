import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:cashback/helpers/api.dart';
import 'package:cashback/helpers/helper.dart';
// import 'package:cashback/helpers/product_controller.dart';

class Index extends StatefulWidget {
  final Function? showHideLoading;
  const Index({Key? key, this.showHideLoading}) : super(key: key);

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  final focus = FocusNode();
  final clientCodeFocus = FocusNode();
  Timer? _debounce;
  // final Controller productController = Get.put(Controller());
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
  bool validate = false;

  debounce(value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      searchUser(value);
    });
  }

  searchUser(value) async {
    if (value.length == 6 || value.length == 12) {
      widget.showHideLoading!(true);
      final prefs = await SharedPreferences.getInstance();
      final response = await get('/services/gocashapi/api/cashbox-user-balance/${prefs.getString('posId')}/$value');
      widget.showHideLoading!(false);
      if (response['id'] != null) {
        setState(() {
          user = response;
          response['lastName'] = response['lastName'] ?? '';
          response['firstName'] = response['firstName'] ?? '';
          // focus.requestFocus();
        });
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(focus);
        });
        return true;
      } else {
        setState(() {
          user = {};
          data['totalAmount'].text = '';
          data['writeOff'].text = '';
          // data['clientCode'].text = '';
          validate = false;
          // data['clientCode'].selection = TextSelection.fromPosition(TextPosition(offset: data['writeOff'].text.length));
        });
        showErrorToast('Пользователь не найден');
        return false;
      }
    }
  }

  createCheque() async {
    print('here');
    if (user['id'] != null && validate && int.parse(data['writeOff'].text == '' ? '0' : data['writeOff'].text) > 0 ||
        int.parse(data['totalAmount'].text == '' ? '0' : data['totalAmount'].text) > 0) {
      widget.showHideLoading!(true);
      var sendData = Map.from(data);
      sendData['clientCode'] = data['clientCode'].text;
      sendData['totalAmount'] = data['totalAmount'].text == '' ? '0' : data['totalAmount'].text;
      sendData['writeOff'] = data['writeOff'].text == '' ? '0' : data['writeOff'].text;
      final response = await post('/services/gocashapi/api/cashbox-create-cheque', sendData);
      if (response['success']) {
        setState(() {
          data['clientCode'].text = '';
          data['totalAmount'].text = '';
          data['writeOff'].text = '';
          data['products'] = [];
          user = {};
          clientCodeFocus.requestFocus();
        });
      }
      widget.showHideLoading!(false);
    }
  }

  deleteProduct(i) {
    dynamic productsCopy = data['products'];
    if (productsCopy.length == 1) {
      // productController.deleteProducts([]);
      setState(() {
        data['products'] = [];
        totalAmount = 0;
        data['totalAmount'].text = '';
        validate = false;
      });
      return;
    }
    productsCopy.removeAt(i);
    for (var i = 0; i < data['products'].length; i++) {
      setState(() {
        totalAmount = data['products'][i]['totalAmount'];
      });
    }
    setState(() {
      data['products'] = productsCopy;
      data['totalAmount'].text = totalAmount.toString();
    });
    // productController.deleteProducts(productsCopy.removeAt(i));
  }

  validateWriteOffField(value) {
    if (user['balance'] != null) {
      // print(int.parse(data['totalAmount'].text == '' ? '0' : data['totalAmount'].text) > int.parse(value));
      if (value.length == previousValue.length) {
        setState(() {
          data['writeOff'].text = '';
          data['writeOff'].selection = TextSelection.fromPosition(TextPosition(offset: data['writeOff'].text.length));
        });
        return;
      }
      setState(() {
        if (user['balance'].round() < int.parse(data['writeOff'].text)) {
          data['writeOff'] = TextEditingController(text: user['balance'].round().toString());
          data['writeOff'].selection = TextSelection.fromPosition(TextPosition(offset: data['writeOff'].text.length));
        }
        if (int.parse(data['totalAmount'].text == '' ? '0' : data['totalAmount'].text) < int.parse(data['writeOff'].text)) {
          data['writeOff'] = TextEditingController(text: data['totalAmount'].text);
          data['writeOff'].selection = TextSelection.fromPosition(TextPosition(offset: data['writeOff'].text.length));
        }
      });
    }
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    await getProduts();
    final user = jsonDecode(prefs.getString('user')!);
    setState(() {
      data = {
        'posId': prefs.getString('posId'),
        'clientCode': TextEditingController(),
        'totalAmount': TextEditingController(),
        'writeOff': TextEditingController(),
        'cashierName': user['username'],
        'products': data['products']
      };
      data['posId'] = prefs.getString('posId');
      // data['cashierName'] = user['username'];
    });
  }

  @override
  void initState() {
    super.initState();
    if (data['products'].length == 0) {
      // setState(() {
      // data['products'] = productController.products;
      // });
    }
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
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.grey[50], // Status bar
        ),
        elevation: 0.0,
        bottomOpacity: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'moneyBek',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showCreateProductDialog();
              },
              icon: Icon(
                Icons.add,
                color: purple,
              )),
          IconButton(
              onPressed: () {
                showSavedProducts();
              },
              icon: Icon(
                Icons.save,
                color: purple,
              )),
          IconButton(
              onPressed: () {
                showCreateUserDialog();
              },
              icon: Icon(
                Icons.person,
                color: purple,
              )),
        ],
      ),
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
                      focusNode: clientCodeFocus,
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
                child: user['id'] != null
                    ? Text(
                        '${user['firstName'] + ' ' + user['lastName']}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      )
                    : null,
              ),
              user['id'] != null
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
                        // enabled: enabled,
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
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                      ],
                      textInputAction: TextInputAction.done,
                      controller: data['writeOff'],
                      keyboardType: TextInputType.number,
                      scrollPadding: const EdgeInsets.only(bottom: 50),
                      onChanged: (value) {
                        validateWriteOffField(value);
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.payments_outlined,
                        ),
                        enabled: int.parse(data['totalAmount'].text == '' ? '0' : data['totalAmount'].text) > 0 && user['id'] != null,
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
                data['products'].length > 0
                    ? Dismissible(
                        key: Key(UniqueKey().toString()),
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
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFF5F3F5), width: 1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${(i + 1)}' '. ' '${data['products'][i]['name']}',
                                    style: const TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                  // Text(
                                  //   'quantity'.tr + ': ${data['products'][i]['quantity']}',
                                  //   overflow: TextOverflow.ellipsis,
                                  //   maxLines: 1,
                                  //   softWrap: false,
                                  // ),
                                  Text(
                                    '${formatMoney(data['products'][i]['price'])}' ' So\'m x ' '${data['products'][i]['quantity']}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ],
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
                                        'barcode'.tr + ': ${data['products'][i]['barcode'].toString()}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${formatMoney(data['products'][i]['totalAmount']).toString()} So\'m',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
              const SizedBox(height: 80)
            ],
          ),
        ),
      )),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(left: 32, bottom: 0),
        width: double.infinity,
        decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(12)),
        child: ElevatedButton(
          onPressed: user['id'] != null && validate || int.parse(data['writeOff'].text == '' ? '0' : data['writeOff'].text) > 0
              ? () {
                  createCheque();
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            onSurface: Colors.black,
            primary: purple,
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

  final _formKey = GlobalKey<FormState>();
  dynamic productList = [
    {'name': 'barcode'.tr, 'field_name': 'barcode', 'inputType': TextInputType.number},
    {'name': 'name'.tr, 'field_name': 'name', 'inputType': TextInputType.text},
    {'name': 'unit'.tr, 'field_name': 'uomId', 'inputType': TextInputType.text},
    {'name': 'price'.tr, 'field_name': 'price', 'inputType': TextInputType.number},
    {'name': 'quantity'.tr, 'field_name': 'quantity', 'inputType': TextInputType.number},
  ];
  dynamic productData = {
    "barcode": TextEditingController(),
    "name": TextEditingController(),
    "uomId": TextEditingController(text: '1'),
    "price": TextEditingController(),
    "quantity": TextEditingController(),
    'id': 0
  };
  List unitList = [
    {'id': 1, 'name': 'шт'},
    {'id': 2, 'name': 'кг'},
    {'id': 3, 'name': 'литр'},
    {'id': 4, 'name': 'м'},
    {'id': 5, 'name': 'гр'},
    {'id': 6, 'name': 'блок'},
    {'id': 7, 'name': 'упаковка'},
    {'id': 8, 'name': 'мл'},
  ];

  addProduct() {
    if (_formKey.currentState!.validate()) {
      var product = {
        "barcode": productData['barcode'].text,
        "name": productData['name'].text,
        "uomId": productData['uomId'].text,
        "price": productData['price'].text,
        "quantity": productData['quantity'].text,
        "totalAmount": int.parse(productData['quantity'].text) * int.parse(productData['price'].text),
      };
      print(product);
      setState(() {
        data['products'].add(product);
        totalAmount = product['totalAmount'] + totalAmount;
        data['totalAmount'].text = totalAmount.toString();
        validate = true;
        productData = {
          "barcode": TextEditingController(),
          "name": TextEditingController(),
          "uomId": TextEditingController(text: '1'),
          "quantity": TextEditingController(),
          "price": TextEditingController(),
          'id': 0
        };
      });
      Get.back();
    }
  }

  showCreateProductDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              // titlePadding: EdgeInsets.all(0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
              title: Text(
                'create_product'.tr,
                textAlign: TextAlign.center,
              ),
              scrollable: true,
              content: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < productList.length; i++)
                          productList[i]['field_name'] != 'uomId'
                              ? Container(
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
                                      scrollPadding: i == 1 || i == 3 ? const EdgeInsets.only(bottom: 200) : EdgeInsets.zero,
                                      controller: productData[productList[i]['field_name']],
                                      onChanged: (value) {},
                                      keyboardType: productList[i]['inputType'],
                                      decoration: InputDecoration(
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
                                        hintText: productList[i]['name'],
                                        hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                                      ),
                                      style: const TextStyle(color: Color(0xFF9C9C9C)),
                                    ),
                                  ))
                              : Container(
                                  // height: 50,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: Color(0xFF9C9C9C)))),
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton(
                                        value: productData['uomId'].text,
                                        isExpanded: true,
                                        hint: Text('${unitList[0]['name']}'),
                                        icon: const Icon(Icons.chevron_right),
                                        iconSize: 24,
                                        iconEnabledColor: purple,
                                        elevation: 16,
                                        style: const TextStyle(color: Color(0xFF313131)),
                                        underline: Container(
                                          height: 2,
                                          color: purple,
                                        ),
                                        onChanged: (newValue) {
                                          setState(() {
                                            productData[productList[i]['field_name']].text = newValue!;
                                          });
                                        },
                                        items: unitList.map((item) {
                                          return DropdownMenuItem<String>(
                                            value: '${item['id']}',
                                            child: Text(item['name']),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                        // const SizedBox(height: 100)
                      ],
                    ),
                  )),
              actions: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      addProduct();
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text('proceed'.tr),
                  ),
                )
              ],
            );
          });
        });
  }

  final quantityFormKey = GlobalKey<FormState>();
  dynamic products = [];
  dynamic prevProducts = [];
  dynamic selectedProduct = [];
  dynamic changedProducts = [];

  getProduts() async {
    final response = await get('/services/gocashapi/api/product-list');
    setState(() {
      products = response;
      prevProducts = List.from(response);
    });
  }

  continueChangeQuantity(item) {
    if (quantityFormKey.currentState!.validate()) {
      setState(() {
        item['totalAmount'] = int.parse(item['quantity']) * item['price'].round();
        changedProducts.add(item);
      });
      Get.back();
    }
  }

  changeQuantity(i) async {
    dynamic item = products[i];
    setState(() {
      item['quantity'] = '1';
    });
    final quantytyFocus = FocusNode();
    final controller = TextEditingController(text: '1');
    controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
              title: Text(
                'quantity'.tr,
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                      child: Form(
                    key: quantityFormKey,
                    child: SizedBox(
                        height: 60,
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
                            onChanged: (value) {
                              setState(() {
                                item['quantity'] = value;
                              });
                            },
                            controller: controller,
                            focusNode: quantytyFocus,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
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
                              hintText: 'quantity'.tr,
                              hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                            ),
                            style: const TextStyle(color: Color(0xFF9C9C9C)),
                          ),
                        )),
                  ))),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), primary: red),
                        child: Text('cancel'.tr),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          continueChangeQuantity(item);
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text('proceed'.tr),
                      ),
                    )
                  ],
                )
              ],
            );
          });
        });
    item = {};
  }

  onSearchTextChanged(String text, productSavedSetSate) async {
    if (text.isEmpty) {
      productSavedSetSate(() {
        products = prevProducts;
      });

      return;
    }
    dynamic arr = [];
    products.forEach((userDetail) {
      if (userDetail['name'].contains(text) || userDetail['barcode'].contains(text)) {
        productSavedSetSate(() {
          arr.add(userDetail);
        });
      }
    });
    productSavedSetSate(() {
      products = arr;
    });
  }

  addProductFromSaved() {
    for (var i = 0; i < changedProducts.length; i++) {
      setState(() {
        totalAmount = changedProducts[i]['totalAmount'] + (totalAmount);
      });
    }
    setState(() {
      data['products'] = [...data['products'], ...changedProducts];
      changedProducts = [];
      data['totalAmount'].text = totalAmount.toString();
      validate = true;
    });
    Get.back();
  }

  showSavedProducts() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, productSavedSetSate) {
            return AlertDialog(
              // titlePadding: EdgeInsets.all(0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
              title: Text(
                'products'.tr,
                textAlign: TextAlign.center,
              ),
              scrollable: true,
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      height: 40,
                      child: TextField(
                        onChanged: (value) {
                          onSearchTextChanged(value, productSavedSetSate);
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(2),
                          isDense: true,
                          prefixIcon: Icon(
                            Icons.search,
                            color: grey,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(18),
                            ),
                          ),
                          focusColor: purple,
                          hintText: 'search_by_name'.tr + ', QR code ...',
                          hintStyle: TextStyle(
                            color: lightGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.52,
                      child: SingleChildScrollView(
                        child: products.length > 0
                            ? Column(
                                children: [
                                  for (var i = 0; i < products.length; i++)
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: white,
                                        border: Border.all(color: borderColor),
                                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black,
                                            spreadRadius: -6,
                                            blurRadius: 5,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${products[i]['name']}',
                                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'barcode'.tr + ': ${products[i]['barcode']}',
                                                    style: TextStyle(color: lightGrey),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'price'.tr + ': ${products[i]['price'].round()}',
                                                    style: TextStyle(color: lightGrey),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  IconButton(
                                                      onPressed: () {
                                                        changeQuantity(i);
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                      icon: Icon(
                                                        Icons.add,
                                                        color: purple,
                                                        size: 28,
                                                      )),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              )
                            : SizedBox(
                                child: Center(
                                  child: Text(
                                    'no_products'.tr,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), primary: red),
                        child: Text('cancel'.tr),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          addProductFromSaved();
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text('proceed'.tr),
                      ),
                    )
                  ],
                )
              ],
            );
          });
        });
  }

  createUser() async {
    dynamic sendData = {'phone': '998' + maskFormatter.getUnmaskedText()};
    final response = await post('/services/gocashapi/api/register-client', sendData);
    if (response['success']) {
      final search = await searchUser('998' + maskFormatter.getUnmaskedText());
      if (search) {
        data['clientCode'].text = '998' + maskFormatter.getUnmaskedText();
      }
    }
    Get.back();
  }

  dynamic maskFormatter = MaskTextInputFormatter(
    mask: '+998 ## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final controller = TextEditingController(text: '+998 ');

  showCreateUserDialog() async {
    dynamic sendData = {
      'phone': '',
    };
    final _formKey = GlobalKey<FormState>();
    final userFocus = FocusNode();

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
              title: Text(
                'quantity'.tr,
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                      child: Form(
                    key: _formKey,
                    child: SizedBox(
                        height: 60,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ThemeData().colorScheme.copyWith(
                                  primary: purple,
                                ),
                          ),
                          child: TextFormField(
                            inputFormatters: [maskFormatter],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'required_field'.tr;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                sendData['phone'] = value;
                              });
                            },
                            controller: controller,
                            focusNode: userFocus,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
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
                              hintText: 'quantity'.tr,
                              hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                            ),
                            style: const TextStyle(color: Color(0xFF9C9C9C)),
                          ),
                        )),
                  ))),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), primary: red),
                        child: Text('cancel'.tr),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            createUser();
                          }
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text('proceed'.tr),
                      ),
                    )
                  ],
                )
              ],
            );
          });
        });
    setState(() {
      controller.text = '+998';
      maskFormatter = MaskTextInputFormatter(
        mask: '+998 ## ### ## ##',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy,
      );
    });
  }
}
