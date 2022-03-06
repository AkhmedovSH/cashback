import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  dynamic user = {};
  DateTime selectedDate = DateTime.now();
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
  List poses = [];

  // searchCheque(value) {
  //   if (value.length > 0) {
  //     if (_debounce?.isActive ?? false) _debounce!.cancel();
  //     _debounce = Timer(const Duration(milliseconds: 1000), () async {
  //       final response = await get('/services/gocashapi/api/cashbox-cheque-pageList', payload: {'search': value});
  //       setState(() {});
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    getCheques();
    getPoses();
  }

  getCheques() async {
    final response = await get('/services/gocashapi/api/cashbox-cheque-pageList', payload: sendData);
    if (response != null) {
      setState(() {
        checks = response;
      });
    }
  }

  getPoses() async {
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
      print(arr);
    }
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
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(8)),
                      onPressed: () {
                        showFilterBottomSheet();
                      },
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
    ));
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

  showFilterBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      builder: (BuildContext context) {
        List statusList = [
          {
            "id": 1,
            "name": 'Подтверждено',
          },
          {
            "id": 2,
            "name": 'Отказано',
          },
          {
            "id": 3,
            "name": 'Ошибка обработки',
          }
        ];
        List posList = poses;
        // List posList = [
        //   {'id': 21, 'name': "M DO'KON"}
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
                              child: const Opacity(
                                opacity: 0.4,
                                child: Text(
                                  'Период',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                                        child: const Opacity(
                                          opacity: 0.4,
                                          child: Text(
                                            'Клиент',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                                        child: const Opacity(
                                          opacity: 0.4,
                                          child: Text(
                                            'Кассир',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                              child: const Text('Фильтр'),
                            ),
                          ))
                    ],
                  ),
                )));
      },
    );
  }
}
