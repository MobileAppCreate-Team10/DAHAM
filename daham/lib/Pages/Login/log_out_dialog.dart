import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:daham/Provider/appstate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showSignOutDialog(BuildContext context) {
  final appState = Provider.of<AppState>(context, listen: false);
  if (appState.user!.isAnonymous) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: 'Sign Out',
      desc:
          'Are you sure you want to sign out? Anonymous User Data will delete!',
      btnOkOnPress: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        await appState.signOut();
        Navigator.of(context, rootNavigator: true).pop(); // 로딩 닫기
        Navigator.pushReplacementNamed(context, '/');
      },
      btnCancelOnPress: () {},
    ).show();

    return;
  }
  AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    title: 'Sign Out',
    desc: 'Are you sure you want to sign out?',
    btnOkOnPress: () async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      await appState.signOut();
      Navigator.of(context, rootNavigator: true).pop(); // 로딩 닫기
      Navigator.pushReplacementNamed(context, '/');
    },
    btnCancelOnPress: () {},
  ).show();
}
