import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cashback/helpers/api.dart';
import 'package:cashback/helpers/helper.dart';

class ChequeById extends StatefulWidget {
  const ChequeById({Key? key}) : super(key: key);

  @override
  State<ChequeById> createState() => _ChequeByIdState();
}

class _ChequeByIdState extends State<ChequeById> {
  dynamic cheque = {};
  dynamic products = [];

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
    return Row(
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
              Center(
                  child: Image.asset(
                'images/cashback_logo.png',
                height: 64,
                width: 200,
              )),
              buildRow('Кассир', cheque['cashierName']),
              buildRow('№ чека', cheque['id']),
              buildRow('Дата', cheque['chequeDate'] != null ? formatDate(cheque['chequeDate']) : ''),
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
                    child: const Text('№ Товар', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: const Text('Кол-во', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: const Text('Цена', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold)),
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
                        '${formatMoney(products[i]['quantity'])}',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${formatMoney(products[i]['amount'])}',
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
              buildRow('Сумма продажи', formatMoney(cheque['totalAmount'])),
            ],
          ),
        ),
      ),
    );
  }
}
