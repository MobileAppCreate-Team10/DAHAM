import 'package:daham/Provider/appstate.dart';
import 'package:daham/Pages/User/profile_setup.dart';
import 'package:daham/app_material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return appState.newAccount == false
            ? Scaffold(
              bottomNavigationBar: BottomNav(),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        TextButton(
                          onPressed: appState.signOut,
                          child: Text('LogOut'),
                        ),
                        Text('Login : ${appState.login}'),
                      ],
                    ),
                    Text('HomePage'),
                  ],
                ),
              ),
            )
            : ProfileSetup();
      },
    );
  }
}
