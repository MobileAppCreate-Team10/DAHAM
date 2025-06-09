import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _select = 0;

  final List<String> _routes = ['/', '/group'];

  void _onTap(int index) {
    setState(() {
      if (index == _select) {
        return;
      }
      _select = index;
      Navigator.pushNamed(context, _routes[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _select,
      onTap: _onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
        BottomNavigationBarItem(icon: Icon(Icons.groups_2), label: 'group'),
      ],
    );
  }
}
