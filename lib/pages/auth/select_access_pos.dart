import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/api.dart';
import '../../helpers/helper.dart';

class SelectAccessPos extends StatefulWidget {
  const SelectAccessPos({Key? key}) : super(key: key);

  @override
  State<SelectAccessPos> createState() => _SelectAccessPosState();
}

class _SelectAccessPosState extends State<SelectAccessPos> {
  dynamic accessPos = [];

  selectAccessPos(posId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('posId', posId.toString());
    Get.offAllNamed('/dashboard');
  }

  @override
  void initState() {
    super.initState();
    getAccessPos();
  }

  getAccessPos() async {
    final response = await get('/services/gocashapi/api/get-access-pos');
    setState(() {
      accessPos = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF7D4196), Color(0xFF776bcc)])),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF7D4196), Color(0xFF776bcc)])),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: white, width: 1))),
                    child: Text(
                      'free_points'.tr,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: white),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'select_merchant_to_enter'.tr,
                      style: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 15),
                  for (var i = 0; i < accessPos.length; i++)
                    Column(
                      children: [
                        // Container(
                        //   margin: const EdgeInsets.only(bottom: 10),
                        //   child: Text(
                        //     accessPos[i]['posGroupName'],
                        //     style: TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.w500),
                        //   ),
                        // ),
                        for (var j = 0; j < accessPos[i]['posList'].length; j++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                // primary: blue,
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                side: const BorderSide(
                                  color: Color.fromARGB(0, 0, 100, 1),
                                ),
                              ),
                              onPressed: () {
                                selectAccessPos(accessPos[i]['posList'][j]['posId']);
                              },
                              child: Text(
                                accessPos[i]['posList'][j]['posName'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
