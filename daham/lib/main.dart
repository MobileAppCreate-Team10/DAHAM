import 'dart:io';

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
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 필수
  try {
    print("test");
    await dotenv.load(fileName: ".env");
    print('dotenv loaded successfully');
    print('GEMINI_API_KEY: ${dotenv.env['GEMINI_API_KEY']}'); // 필요시 확인
  } catch (e) {
    print('Main Failed to load .env file: $e');
    // 여기서 오류 발생 시 runApp이 호출되지 않을 수 있습니다.
  }

  // GeminiProvider 인스턴스 생성 및 API 키 로드
  final geminiProvider = GeminiProvider(); // GeminiProvider 정의를 확인해야 합니다.
  try {
    await geminiProvider.loadApiKey(); // 이 부분이 성공적으로 완료되어야 합니다.
    print('GeminiProvider API key loaded successfully');
  } catch (e) {
    print('Failed to load GeminiProvider API key: $e');
    // 여기서 오류 발생 시 runApp이 호출되지 않을 수 있습니다.
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: geminiProvider,
        ), // API 키가 로드된 Provider
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => TodoState()),
        // 만약 SettingsProvider를 사용한다면 여기에 추가
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
            '/group': (context) => GroupListPage(),
          },
        );
      },
    );
  }
}
