import 'package:daham/Pages/HomePage/mainFrame.dart';
import 'package:daham/Pages/Group/group_list_page.dart';
import 'package:daham/Pages/Login/login.dart';
import 'package:daham/Pages/User/profile_setup.dart';
import 'package:daham/Provider/export.dart';
import 'package:daham/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => TodoState()),
      ],
      child: const RootApp(),
    ),
  );
}

// 처음 앱 시작 시 Firebase 초기화 후 Daham 앱을 실행
class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) return Daham();
        // Loading
        return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}

class Daham extends StatefulWidget {
  const Daham({super.key});

  @override
  State<Daham> createState() => _DahamState();
}

class _DahamState extends State<Daham> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (!_initialized) {
      Provider.of<AppState>(context, listen: false).init(context);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          supportedLocales: [Locale('en'), Locale('ko')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FormBuilderLocalizations.delegate,
          ],

          home: state.login != true ? Login() : MainScaffold(),
          routes: {
            '/profileSetting': (context) => ProfileSetup(),
            '/sign': (context) => Login(),
            // '/': (context) => HomePage(),
            '/group': (context) => GroupListPage(),
          },
        );
      },
    );
  }
}
