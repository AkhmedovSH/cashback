import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:cashback/helpers/helper.dart';
import 'package:cashback/helpers/api.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  dynamic products = [];
  dynamic prevProducts = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getProduts();
  }

  getProduts() async {
    setState(() {
      loading = true;
    });
    final response = await get('/services/gocashapi/api/product-list');
    setState(() {
      products = response;
      prevProducts = List.from(response);
      loading = false;
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
                  setState(() {
                    update = false;
                  });
                  showCreateProductDialog();
                },
                icon: Icon(
                  Icons.add,
                  color: purple,
                ))
          ]),
      body: !loading
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
                                    'price'.tr + ': ${products[i]['price']}',
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
                                        showUpdateProductModal(products[i]['id']);
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
            ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  dynamic data = {
    "barcode": TextEditingController(),
    "name": TextEditingController(),
    "uomId": TextEditingController(text: '1'),
    "price": TextEditingController(),
    'id': 0
  };
  dynamic update = false;
  dynamic productList = [
    {'name': 'barcode'.tr, 'field_name': 'barcode', 'inputType': TextInputType.number},
    {'name': 'name'.tr, 'field_name': 'name', 'inputType': TextInputType.text},
    {'name': 'unit'.tr, 'field_name': 'uomId', 'inputType': TextInputType.text},
    {'name': 'price'.tr, 'field_name': 'price', 'inputType': TextInputType.number},
  ];
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

  createProduct() async {
    setState(() {
      data['uomId'].text = '1';
    });
    var sendData = {
      "barcode": data['barcode'].text,
      "name": data['name'].text,
      "uomId": data['uomId'].text,
      "price": data['price'].text,
    };
    final response = await post('/services/gocashapi/api/product', sendData);
    if (response['success']) {
      getProduts();
      showSuccessToast('product_created_successfully'.tr);
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
      showSuccessToast('product_updated_successfully'.tr);
      getProduts();
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
                                      inputFormatters: i == 3
                                          ? [
                                              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                            ]
                                          : [],
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
                      if (update) {
                        updateProduct();
                      } else {
                        createProduct();
                      }
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(!update ? 'proceed'.tr : 'save'.tr),
                  ),
                )
              ],
            );
          });
        });
  }
}
