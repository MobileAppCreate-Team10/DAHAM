import 'package:daham/Provider/appstate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false; // 로그인 중 상태

  Future<void> _signInGoogle(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      // 로그인 성공 시 자동으로 MainScaffold로 이동됨
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 실패')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInAnonymous(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      // 익명 로그인 성공 시 바로 newAccount true로!
      Provider.of<AppState>(context, listen: false).setNewAccount(true);
      // 또는 AppState에서 로그인 감지 시 자동으로 newAccount = true 처리
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/lottie/plane.json'),
                    SizedBox(height: 29),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton.icon(
                        icon: Image.network(
                          'https://developers.google.com/identity/images/g-logo.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text('Sign in with Google'),
                        onPressed: () => _signInGoogle(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () => _signInAnonymous(context),
                        child: const Text('Anonymous Login-in'),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
