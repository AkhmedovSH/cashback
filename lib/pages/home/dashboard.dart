import 'package:flutter/material.dart';

import 'package:cashback/helpers/helper.dart';

import '../../components/bottom/bottom_navigation.dart';
import './index.dart';
import './reports.dart';
import 'cheques.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  dynamic drawerList = [
    {'title': 'Чеки', 'routeName': '/check-create'}
  ];

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
                  onPressed: () {},
                  icon: Icon(
                    Icons.add,
                    color: purple,
                  ))
              : Container(),
          currentIndex == 0
              ? IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.save,
                    color: purple,
                  ))
              : Container()
        ],
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
          currentIndex == 0 ? const Index() : Container(),
          currentIndex == 1 ? const Reports() : Container(),
          currentIndex == 2 ? const Checks() : Container(),
        ],
      ),
      //screens[currentIndex]
    );
  }
}
