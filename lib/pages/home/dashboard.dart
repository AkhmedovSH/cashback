import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cashback/helpers/helper.dart';

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
  GlobalKey globalKey = GlobalKey();
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentIndex = 0;
  dynamic drawerList = [
    {'title': 'Чеки', 'routeName': '/check-create'}
  ];
  dynamic productList = [
    {'name': 'barcode'.tr, 'field_name': 'barcode', 'inputType': TextInputType.number},
    {'name': 'name'.tr, 'field_name': 'name', 'inputType': TextInputType.text},
    {'name': 'unit'.tr, 'field_name': 'unit', 'inputType': TextInputType.text},
    {'name': 'quantity'.tr, 'field_name': 'quantity', 'inputType': TextInputType.number},
    {'name': 'price'.tr, 'field_name': 'amount', 'inputType': TextInputType.number},
  ];
  dynamic data = {"barcode": "", "name": "", "unit": "шт", "quantity": '0', "amount": '0'};
  dynamic products = [];
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

        // Icon for Drawer

        // leading: IconButton(
        //   onPressed: () {
        //     _scaffoldKey.currentState!.openDrawer();
        //   },
        //   icon: const Icon(
        //     Icons.menu,
        //     color: Colors.black,
        //   ),
        // ),
      ),
      // drawer: SizedBox(
      //   width: MediaQuery.of(context).size.width * 0.8,
      //   child: Drawer(
      //       child: SafeArea(
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         for (var i = 0; i < drawerList.length; i++)
      //           TextButton(
      //             onPressed: () {},
      //             child: Text(
      //               'Чеки',
      //             ),
      //           )
      //       ],
      //     ),
      //   )),
      // ),
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
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < productList.length; i++)
                          productList[i]['field_name'] != 'unit'
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
                                        value: data['unit'],
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
                                          print(data);
                                        },
                                        items: unitList.map((item) {
                                          return DropdownMenuItem<String>(
                                            value: '${item['name']}',
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
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          products.add(data);
                          data = {"barcode": "", "name": "", "unit": "шт", "quantity": '0', "amount": '0'};
                        });
                        Get.back();
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
