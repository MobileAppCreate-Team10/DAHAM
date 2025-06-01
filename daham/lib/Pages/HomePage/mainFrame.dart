import 'package:daham/Pages/Group/group_list_page.dart';
import 'package:daham/Pages/HomePage/main_page.dart';
import 'package:daham/Pages/User/my_page.dart';
import 'package:daham/Pages/User/profile_setup.dart';
import 'package:daham/Provider/appstate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _select = 0;

  final List<Widget> _pages = [
    MainPage(),
    GroupListPage(),
    ProfileDetailSetup(),
    MyPage(),
  ];
  final List<Widget?> _fab = [
    FloatingActionButton(onPressed: () {}),
    GroupFAB(),
    null,
  ];
  void _onTap(int index) {
    setState(() {
      _select = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return appState.newAccount == false
            ? Scaffold(
              body: IndexedStack(index: _select, children: _pages),
              bottomNavigationBar: BottomNav(
                currentIndex: _select,
                onTap: _onTap,
              ),
              floatingActionButton: _fab[_select],
            )
            : ProfileSetup();
      },
    );
  }
}

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'group'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My'),
      ],
    );
  }
}
