import 'package:cashback/helpers/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashback/helpers/helper.dart';

class Products extends StatefulWidget {
  final dynamic products;
  final Function addToList;
  const Products({Key? key, this.products, required this.addToList}) : super(key: key);

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  dynamic products = [];

  @override
  void initState() {
    super.initState();
    getProduts();
  }

  getProduts() async {
    final response = await get('/services/gocashapi/api/product-list');
    setState(() {
      products = response;
    });
    print(response);
  }

  addProductToSell() {}

  onSearchTextChanged(String text) async {
    // _searchResult.clear();
    if (text.isEmpty) {
      setState(() {
        products = widget.products;
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
      body: SafeArea(
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
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              // widget.addToList(products[i]);
                              // addProductToSell();
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(
                              Icons.add,
                              color: purple,
                            ))
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ))),
    );
  }
}
