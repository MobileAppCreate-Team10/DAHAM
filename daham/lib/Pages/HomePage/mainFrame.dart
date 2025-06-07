import 'package:daham/Pages/Group/group_list_page.dart';
import 'package:daham/Pages/HomePage/userMain_Todo.dart';
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
    MyPage(),
    ProfileDetailSetup(),
  ];
  final List<Widget?> _fab = [UserTodoFAB(), GroupFAB(), null, null];

  final List<PreferredSizeWidget?> _appBar = [
    null,
    null,
    null,
    UserPageAppBar(),
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
              appBar: _appBar[_select],
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
      type: BottomNavigationBarType.shifting,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: '그룹'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
      ],
    );
  }
}
