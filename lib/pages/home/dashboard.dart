import 'package:cashback/helpers/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cashback/helpers/helper.dart';
import 'package:cashback/helpers/productController.dart';

import '../../components/bottom/bottom_navigation.dart';
import './index.dart';
import './products.dart';
import 'cheques.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _formKey = GlobalKey<FormState>();
  final Controller productController = Get.put(Controller());
  GlobalKey globalKey = GlobalKey();
  int currentIndex = 0;
  dynamic drawerList = [
    {'title': 'Чеки', 'routeName': '/check-create'}
  ];
  dynamic productList = [
    {'name': 'barcode'.tr, 'field_name': 'barcode', 'inputType': TextInputType.number},
    {'name': 'name'.tr, 'field_name': 'name', 'inputType': TextInputType.text},
    {'name': 'unit'.tr, 'field_name': 'uomId', 'inputType': TextInputType.text},
  ];
  dynamic data = {"barcode": "", "name": "", "uomId": "1", "quantity": '0', "amount": '0'};
  dynamic products = [].obs;
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

  createProduct() async {
    setState(() {
      data['uomId'] = '1';
    });
    final response = await post('/services/gocashapi/api/product', data);
    if (response['success']) {
      Get.back();
    }
  }

  updateProduct() async {
    final response = await put('/services/gocashapi/api/product', data);
    print(response);
  }

  addProduct() {
    if (_formKey.currentState!.validate()) {
      productController.addProduct(data);
      setState(() {
        products.add(data);
        data = {"barcode": "", "name": "", "uomId": "1", "quantity": '0', "amount": '0'};
      });
      Get.back();
    }
  }

  addToList(item) {
    productController.addProduct(item);
    print(item);
    setState(() {
      products.add(item);
    });
  }

  clearProducts() {
    setState(() {
      products = [];
    });
  }

  @override
  void initState() {
    super.initState();
  }

  changeIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // elevation: 0,
        title: const Text(
          'moneyBek',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          currentIndex == 0 || currentIndex == 1
              ? IconButton(
                  onPressed: () {
                    showCreateProductDialog();
                  },
                  icon: Icon(
                    Icons.add,
                    color: purple,
                  ))
              : Container(),
          currentIndex == 2
              ? IconButton(
                  onPressed: () {
                    // globalKey.currentState?.printSample();
                  },
                  icon: Icon(
                    Icons.filter_alt_outlined,
                    color: purple,
                  ))
              : Container(),
          // currentIndex == 0
          //     ? IconButton(
          //         onPressed: () {},
          //         icon: Icon(
          //           Icons.save,
          //           color: purple,
          //         ))
          //     : Container()
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        changeIndex: changeIndex,
        currentIndex: currentIndex,
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          currentIndex == 0
              ? Index(
                  products: products,
                  clearProducts: clearProducts,
                )
              : Container(),
          currentIndex == 1
              ? Products(
                  products: products,
                  addToList: addToList,
                )
              : Container(),
          currentIndex == 2 ? Checks(key: globalKey) : Container(),
        ],
      ),
      //screens[currentIndex]
    );
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
                  height: MediaQuery.of(context).size.height * 0.35,
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
                                      onChanged: (value) {
                                        data[productList[i]['field_name']] = value;
                                      },
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
                                        value: data['uomId'],
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
                                            data[productList[i]['field_name']] = newValue!;
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
                                )
                      ],
                    ),
                  )),
              actions: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentIndex == 0) {
                        addProduct();
                      }
                      if (currentIndex == 1) {
                        createProduct();
                      }
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
}
