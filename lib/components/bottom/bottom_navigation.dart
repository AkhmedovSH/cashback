import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  final Function changeIndex;
  final int currentIndex;
  const BottomNavigation({Key? key, required this.changeIndex, required this.currentIndex}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  void onSelectMenu(int index) async {
    widget.changeIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF7D4196),
      currentIndex: widget.currentIndex,
      onTap: onSelectMenu,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Чеки'),
      ],
    );
  }
}
