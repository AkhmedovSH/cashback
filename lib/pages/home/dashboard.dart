import 'package:cashback/helpers/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:cashback/helpers/helper.dart';
import 'package:cashback/helpers/product_controller.dart';

import '../../components/bottom/bottom_navigation.dart';
import './index.dart';
import './products.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  AnimationController? animationController;
  final Controller productController = Get.put(Controller());
  GlobalKey globalKey = GlobalKey();
  bool loading = false;
  bool localLoading = true;
  int currentIndex = 0;
  dynamic drawerList = [
    {'title': 'Чеки', 'routeName': '/check-create'}
  ];
  dynamic productList = [
    {'name': 'barcode'.tr, 'field_name': 'barcode', 'inputType': TextInputType.number},
    {'name': 'name'.tr, 'field_name': 'name', 'inputType': TextInputType.text},
    {'name': 'unit'.tr, 'field_name': 'uomId', 'inputType': TextInputType.text},
    {'name': 'price'.tr, 'field_name': 'price', 'inputType': TextInputType.number},
  ];
  dynamic data = {
    "barcode": TextEditingController(),
    "name": TextEditingController(),
    "uomId": TextEditingController(text: '1'),
    "price": TextEditingController(),
    'id': 0
  };
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
  DateTime selectedDate = DateTime.now();
  List poses = [];
  dynamic checks = [];
  dynamic update = false;

  dynamic pageProducts = [];
  dynamic prevProducts = [];
  bool productsLoading = false;

  dynamic filter = {
    'startDate': TextEditingController(),
    'endDate': TextEditingController(),
    'search': TextEditingController(),
    'clientLogin': TextEditingController(),
    'cashierName': TextEditingController(),
  };
  dynamic sendData = {
    'startDate': '',
    'endDate': '',
    'posId': '1',
    'status': '1',
    'clientLogin': '',
    'cashierName': '',
  };

  createProduct() async {
    setState(() {
      data['uomId'].text = '1';
    });
    final response = await post('/services/gocashapi/api/product', data);
    if (response['success']) {
      Get.back();
    }
  }

  updateProduct() async {
    final sendData = {
      'name': data['name'].text,
      'barcode': data['barcode'].text,
      'uomId': data['uomId'].text,
      'price': data['price'].text,
      'id': data['id'],
    };
    final response = await put('/services/gocashapi/api/product', sendData);
    if (response['success']) {
      Get.back();
      setState(() {
        update = false;
        data['name'].text = '';
        data['barcode'].text = '';
        data['uomId'].text = '1';
        data['price'].text = '';
      });
      getProduts();
    }
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
    showSuccessToast('Продукт добавлен в список');
  }

  showUpdateProductModal(id) async {
    final response = await get('/services/gocashapi/api/product/$id');
    if (response['id'] != null) {
      setState(() {
        data['name'].text = response['name'].toString();
        data['barcode'].text = response['barcode'].toString();
        data['uomId'].text = response['uomId'].toString();
        data['price'].text = response['price'].round().toString();
        data['id'] = response['id'].toString();
        update = true;
      });
      showCreateProductDialog();
    }
  }

  showHideLoading(bool bool) {
    setState(() {
      loading = bool;
    });
  }

  clearProducts() {
    setState(() {
      products = [];
    });
  }

  getCheques() async {
    setState(() {
      localLoading = false;
    });
    final response = await get('/services/gocashapi/api/cashbox-cheque-pageList', payload: sendData);
    if (response != null) {
      setState(() {
        checks = response;
      });
    }
    setState(() {
      localLoading = true;
    });
  }

  getProduts() async {
    setState(() {
      productsLoading = true;
    });
    final response = await get('/services/gocashapi/api/product-list');
    setState(() {
      pageProducts = response;
      prevProducts = List.from(response);
      productsLoading = false;
    });
  }

  onSearchTextChanged(String text) async {
    if (text.isEmpty) {
      setState(() {
        products = prevProducts;
      });
      return;
    }
    dynamic arr = [];
    products.forEach((userDetail) {
      if (userDetail['name'].contains(text) || userDetail['barcode'].contains(text)) {
        setState(() {
          arr.add(userDetail);
        });
      }
    });

    setState(() {
      products = arr;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    });
  }

  changeIndex(int index) {
    setState(() {
      currentIndex = index;
    });
    if (currentIndex == 1) {
      getProduts();
    }
    if (currentIndex == 2) {
      getCheques();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
              currentIndex == 0 || currentIndex == 1
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          update = false;
                        });
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
                        showFilterBottomSheet();
                      },
                      icon: Icon(
                        Icons.filter_alt_outlined,
                        color: purple,
                      ))
                  : Container(),
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
                      showHideLoading: showHideLoading,
                    )
                  : Container(),
              currentIndex == 1
                  ? !productsLoading
                      ? SafeArea(
                          child: SingleChildScrollView(
                              child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 20),
                                height: 40,
                                child: TextField(
                                  onChanged: onSearchTextChanged,
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
                                    hintText: 'search_by_name'.tr + ', QR code ...',
                                    hintStyle: TextStyle(
                                      color: lightGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              for (var i = 0; i < pageProducts.length; i++)
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
                                        '${pageProducts[i]['name']}',
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
                                                'barcode'.tr + ': ${pageProducts[i]['barcode']}',
                                                style: TextStyle(color: lightGrey),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'price'.tr + ': ${pageProducts[i]['price']}',
                                                style: TextStyle(color: lightGrey),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    addToList(pageProducts[i]);
                                                    // addProductToSell();
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  icon: Icon(
                                                    Icons.add,
                                                    color: purple,
                                                    size: 28,
                                                  )),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    showUpdateProductModal(pageProducts[i]['id']);
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  icon: Icon(
                                                    Icons.edit,
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
                          ),
                        )))
                      : Center(
                          child: CircularProgressIndicator(color: purple),
                        )
                  : Container(),
              currentIndex == 2
                  ? localLoading
                      ? SafeArea(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      child: Column(
                                        children: [
                                          Table(
                                            children: [
                                              TableRow(children: [
                                                Text(
                                                  'date'.tr,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'check_amount'.tr,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ]),
                                              for (var i = 0; i < checks.length; i++)
                                                TableRow(children: [
                                                  GestureDetector(
                                                      onTap: () {
                                                        Get.toNamed('/cheque-by-id', arguments: checks[i]['id']);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                        // decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(50)),
                                                        child: Text(
                                                          '${formatDate(checks[i]['chequeDate'])}',
                                                          style: TextStyle(color: checks[i]['status'] == 1 ? blue : red),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      )),
                                                  GestureDetector(
                                                      onTap: () {
                                                        Get.toNamed('/cheque-by-id', arguments: checks[i]['id']);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                        child: Text(
                                                          '${formatMoney(checks[i]['totalAmount'])}',
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ))
                                                ])
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(color: purple),
                        )
                  : Container(),
            ],
          ),
        ),
        loading
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.4),
                child: SpinKitThreeBounce(
                  color: purple,
                  size: 35.0,
                  controller: animationController,
                ),
              )
            : Container()
      ],
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
                !update ? 'create_product'.tr : 'update_product'.tr,
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
                                      controller: data[productList[i]['field_name']],
                                      onChanged: (value) {
                                        // data[productList[i]['field_name']] = value;
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
                                        value: data['uomId'].text,
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
                                            data[productList[i]['field_name']].text = newValue!;
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
                        if (update) {
                          updateProduct();
                        } else {
                          createProduct();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(!update ? 'proceed'.tr : 'update'.tr),
                  ),
                )
              ],
            );
          });
        });
  }

  getPoses() async {
    setState(() {
      loading = true;
    });
    final response = await get('/services/gocashapi/api/get-access-pos');
    if (response != null) {
      dynamic arr = [];
      for (var i = 0; i < response.length; i++) {
        for (var j = 0; j < response[i]['posList'].length; j++) {
          arr.add(response[i]['posList'][i]);
        }
      }
      setState(() {
        sendData['posId'] = arr[0]['posId'].toString();
        poses = arr;
      });
    }
    setState(() {
      loading = false;
    });
  }

  showFilterBottomSheet() async {
    await getPoses();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      builder: (BuildContext context) {
        List statusList = [
          {
            "id": 1,
            "name": 'confirmed'.tr,
          },
          {
            "id": 2,
            "name": 'denied'.tr,
          },
          {
            "id": 3,
            "name": 'processing_error'.tr,
          }
        ];
        List posList = poses;
        update = update;
        // List posList = [
        //   {'id': 21, 'posName': "M DO'KON"}
        // ];
        return StatefulBuilder(
            builder: ((context, setState) => Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 50, bottom: 5),
                              child: Opacity(
                                opacity: 0.4,
                                child: Text(
                                  'period'.tr,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    selectDate(context, 1);
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.44,
                                    child: TextField(
                                      controller: filter['startDate'],
                                      textInputAction: TextInputAction.next,
                                      enabled: false,
                                      enableInteractiveSelection: false,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xFFced4da),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xFFced4da),
                                            width: 1,
                                          ),
                                        ),
                                        hintStyle: TextStyle(color: Color(0xFF495057)),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    selectDate(context, 2);
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.44,
                                    child: TextField(
                                      controller: filter['endDate'],
                                      textInputAction: TextInputAction.next,
                                      enabled: false,
                                      enableInteractiveSelection: false,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xFFced4da),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xFFced4da),
                                            width: 1,
                                          ),
                                        ),
                                        hintStyle: TextStyle(color: Color(0xFF495057)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20, bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 5),
                                        child: Opacity(
                                          opacity: 0.4,
                                          child: Text(
                                            'client'.tr,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.44,
                                        child: TextField(
                                          controller: filter['clientLogin'],
                                          textInputAction: TextInputAction.next,
                                          onChanged: (value) {
                                            setState(() {
                                              sendData['clientLogin'] = value;
                                            });
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFFced4da),
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFFced4da),
                                                width: 1,
                                              ),
                                            ),
                                            hintText: '',
                                            hintStyle: TextStyle(color: Color(0xFF495057)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 5),
                                        child: Opacity(
                                          opacity: 0.4,
                                          child: Text(
                                            'cashier'.tr,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.44,
                                        child: TextField(
                                          controller: filter['cashierName'],
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            setState(() {
                                              sendData['cashierName'] = value;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFFced4da),
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFFced4da),
                                                width: 1,
                                              ),
                                            ),
                                            hintText: '',
                                            hintStyle: TextStyle(color: Color(0xFF495057)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.44,
                                  // height: 50,
                                  decoration: const ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Color(0xFFECECEC)),
                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton(
                                        value: sendData['status'],
                                        isExpanded: true,
                                        hint: Text('${statusList[0]['name']}'),
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
                                            sendData['status'] = newValue;
                                          });
                                        },
                                        items: statusList.map((item) {
                                          return DropdownMenuItem<String>(
                                            value: '${item['id']}',
                                            child: Text(item['name']),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  // height: 50,
                                  width: MediaQuery.of(context).size.width * 0.44,
                                  decoration: const ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Color(0xFFECECEC)),
                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton(
                                        isExpanded: true,
                                        hint: Text('${posList[0]['posName']}'),
                                        icon: const Icon(Icons.chevron_right),
                                        iconSize: 24,
                                        iconEnabledColor: purple,
                                        elevation: 16,
                                        style: const TextStyle(color: Color(0xFF313131)),
                                        underline: Container(
                                          height: 2,
                                          color: purple,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            sendData['posId'] = newValue!;
                                          });
                                        },
                                        items: posList.map((item) {
                                          return DropdownMenuItem<String>(
                                            value: '${item['posId']}',
                                            child: Text(item['posName']),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ElevatedButton(
                              onPressed: () {
                                getCheques();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: Text('filter'.tr),
                            ),
                          ))
                    ],
                  ),
                )));
      },
    );
  }

  selectDate(BuildContext context, date) async {
    final DateTime? picked =
        await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (date == 1) {
      if (picked != null && picked != filter['startDate'].text) {
        setState(() {
          filter['startDate'].text = DateFormat('dd.MM.yyyy').format(picked);
          sendData['startDate'] = DateFormat('dd.MM.yyyy').format(picked);
        });
      }
    }
    if (date == 2) {
      if (picked != null && picked != filter['startDate'].text) {
        setState(() {
          filter['endDate'].text = DateFormat('dd.MM.yyyy').format(picked);
          sendData['endDate'] = DateFormat('dd.MM.yyyy').format(picked);
        });
      }
    }
  }
}
