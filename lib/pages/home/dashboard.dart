import 'package:flutter/material.dart';

import '../../components/bottom/BottomNavigation.dart';
import './index.dart';
import './reports.dart';
import './checks.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // if (widget.index != null) {
    //   setState(() {
    //     currentIndex = widget.index!;
    //   });
    // }
  }

  changeIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
