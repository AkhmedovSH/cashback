import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:cashback/helpers/helper.dart';

import '../../components/bottom/bottom_navigation.dart';
import './index.dart';
import './products.dart';
import './cheques.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  AnimationController? animationController;
  bool loading = false;
  int currentIndex = 0;

  showHideLoading(bool bool) {
    setState(() {
      loading = bool;
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
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          bottomNavigationBar: BottomNavigation(
            changeIndex: changeIndex,
            currentIndex: currentIndex,
          ),
          body: IndexedStack(
            index: currentIndex,
            children: [
              currentIndex == 0
                  ? Index(
                      showHideLoading: showHideLoading,
                    )
                  : Container(),
              currentIndex == 1 ? const Products() : Container(),
              currentIndex == 2 ? const Checks() : Container(),
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
}
