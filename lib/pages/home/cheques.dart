import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cashback/helpers/api.dart';
import 'package:cashback/helpers/helper.dart';
import 'package:get/get.dart';

class Checks extends StatefulWidget {
  const Checks({Key? key}) : super(key: key);

  @override
  State<Checks> createState() => _ChecksState();
}

class _ChecksState extends State<Checks> {
  dynamic checks = [];
  Timer? _debounce;

  searchCheque(value) {
    if (value.length > 0) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 1000), () async {
        final response = await get('/services/gocashapi/api/cheque-pageList', payload: {'search': value});
        print(response);
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getChecks();
  }

  getChecks() async {
    final response = await get('/services/gocashapi/api/cheque-pageList');
    print(response);
    if (response != null) {
      setState(() {
        checks = response;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      onChanged: (value) {
                        searchCheque(value);
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(18.0),
                        focusColor: Color(0xFF7D4196),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFced4da)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFced4da)),
                        ),
                        hintText: 'Поиск',
                        hintStyle: TextStyle(color: Color(0xFF9C9C9C)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(8)),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.filter_alt_outlined), Text('Фильтр')],
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Table(
                        children: [
                          const TableRow(children: [
                            Text(
                              'Дата',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Сумма чека	',
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
                                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                                    padding: const EdgeInsets.symmetric(vertical: 8),
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
    ));
  }
}
