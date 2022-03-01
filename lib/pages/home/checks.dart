import 'package:flutter/material.dart';

import 'package:cashback/helpers/api.dart';
import 'package:cashback/helpers/helper.dart';

class Checks extends StatefulWidget {
  const Checks({Key? key}) : super(key: key);

  @override
  State<Checks> createState() => _ChecksState();
}

class _ChecksState extends State<Checks> {
  dynamic checks = [];

  @override
  void initState() {
    super.initState();
    getChecks();
  }

  getChecks() async {
    final response = await get('/services/gocashweb/api/cheque-pageList');
    setState(() {
      checks = response;
    });
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
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(18.0),
                        focusColor: Color(0xFF7D4196),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFced4da)),
                        ),
                        focusedBorder: UnderlineInputBorder(
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
                scrollDirection: Axis.horizontal,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width * 2,
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
                              'Оплатили в сумах	',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Оплатили в сумах	',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Оплатили в сумах	',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Оплатили в сумах	',
                              textAlign: TextAlign.center,
                            ),
                            Text('Сумма чека'),
                          ]),
                          // for (var i = 0; i < checks.length; i++) TableRow()
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
