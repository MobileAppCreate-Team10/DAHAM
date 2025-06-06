import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //
  Future<void> _signInGoogle(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn();
      // await googleSignIn.signOut(); // 로그인때마다 계정 선택하기

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      // print('sign button press');
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      // print('token get');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // ignore: use_build_context_synchronously
      // Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      //TODO : MessageBox - login error
    }
  }

  Future<void> _signInAnonymous(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      // Navigator.of(context).popAndPushNamed('/');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
