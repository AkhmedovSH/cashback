import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cashback/helpers/helper.dart';

import '../../components/bottom/bottom_navigation.dart';
import './index.dart';
import './cheques.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentIndex = 0;
  dynamic drawerList = [
    {'title': 'Чеки', 'routeName': '/check-create'}
  ];
  dynamic productList = [
    {'name': 'Штрих-код', 'field_name': 'barcode', 'inputType': TextInputType.number},
    {'name': 'Название', 'field_name': 'name', 'inputType': TextInputType.text},
    {'name': 'Единица измерения', 'field_name': 'unit', 'inputType': TextInputType.text},
    {'name': 'Количество', 'field_name': 'quantity', 'inputType': TextInputType.number},
    {'name': 'Цена', 'field_name': 'amount', 'inputType': TextInputType.number},
  ];
  dynamic data = {"barcode": "", "name": "", "unit": "", "quantity": '0', "amount": '0'};
  dynamic products = [];

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
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // elevation: 0,
        title: const Text(
          'CashBek',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          currentIndex == 0
              ? IconButton(
                  onPressed: () {
                    showCreateProductDialog();
                  },
                  icon: Icon(
                    Icons.add,
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
          currentIndex == 1 ? const Checks() : Container(),
        ],
      ),
      //screens[currentIndex]
    );
  }

  showCreateProductDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        // titlePadding: EdgeInsets.all(0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
        title: const Text(
          'Создать продукт',
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
                    Container(
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
                                return 'Обязательное поле';
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
                        )),
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
                    data = {"barcode": "", "name": "", "unit": "", "quantity": '0', "amount": '0'};
                  });
                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Продолжить'),
            ),
          )
        ],
      ),
    );
  }
}
