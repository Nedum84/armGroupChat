import 'dart:async';
import 'package:arm_group_chat/screen/login/login_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'chat/chat_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2),(){
      _checkSignedIn();
    });
  }

  _checkSignedIn() async {
    // setState(() => _loadingStage = LoadingStage.LOADING);
    Firebase.initializeApp().whenComplete(() async {
      FirebaseAuth.instance.authStateChanges().listen((User user) async {
        if (user != null) {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ChatScreen();
              },
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return LoginRegister();
              },
            ),
          );
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white70,
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('ARM Group Chat',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),),
        ),
      ),
    );
  }
}
