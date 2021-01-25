import 'package:arm_group_chat/screen/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:arm_group_chat/utils/colors.dart';
import 'package:arm_group_chat/repository/auth_repo.dart';
import 'package:arm_group_chat/utils/alert_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginRegister extends StatefulWidget {
  @override
  _LoginRegisterState createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailFieldFocus = FocusNode();
  FocusNode passwordFieldFocus = FocusNode();

  AuthRepo _authRepo;

  LogRegState logRegState = LogRegState.LOGIN;

  @override
  void initState() {
    super.initState();
    _checkSignedIn();
  }

  _checkSignedIn() async {
    // setState(() => _loadingStage = LoadingStage.LOADING);
    Firebase.initializeApp().whenComplete(() async {
      _authRepo = AuthRepo();
      FirebaseAuth.instance.authStateChanges().listen((User user) async {
        if (user != null) {
          gotoHomePage();
        } else {
          // setState(() => _loadingStage = LoadingStage.NOT_LOADING);
        }
      });
    });
  }

  _toggleState(){
    if(logRegState == LogRegState.LOGIN)
      setState(() => logRegState = LogRegState.REGISTER);
    else
      setState(() => logRegState = LogRegState.LOGIN);
  }

  _logOrReg() {
    emailFieldFocus.unfocus();
    passwordFieldFocus.unfocus();

    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    //
    if(email.isEmpty||email.isEmpty){
      AlertUtils.toast('Email & password are required');
    }else {
      if(logRegState == LogRegState.REGISTER){
        _emailRegister(email, password);
      }else{
        _emailSignIn(email, password);
      }
    }
  }
  _emailRegister(String email, String password) async {
    try {
      final newUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if (newUser != null) {
        AlertUtils.toast("Registration successful.");
        authenticateUser(newUser.user);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        AlertUtils.toast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        AlertUtils.toast('The account already exists for that email.');
      }else{
        AlertUtils.toast('${e.code}');
      }
    } catch (e) {//e is the error message like 'The email address is already in use by another account.'
      print(e);
    }
  }
  _emailSignIn(String email, String password) async {
    try {
      final newUser = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (newUser != null) {
        AlertUtils.toast("Login successful");
        authenticateUser(newUser.user);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        AlertUtils.toast('Invalid Credentials');
      } else if (e.code == 'email-already-in-use') {
        AlertUtils.toast('The account already exists for that email.');
      }else {
        AlertUtils.toast('${e.code}');
        print(e.code);
      }
    } catch (e) {//e is the error message like 'The email address is already in use by another account.'
      print(e);
    }
  }


  void _facebookSignIn() async {
    User user = await _authRepo.facebookSignIn();

    if (user != null) {
      AlertUtils.toast("Signing you in, please wait...");
      authenticateUser(user);
    }
  }

  void _googleSignIn() async {
    User user = await _authRepo.googleSignIn();
    if (user != null) {
      AlertUtils.toast("Signing you in, please wait...");
      authenticateUser(user);
    }
  }

  void authenticateUser(User user) async {

    _authRepo.authenticateUser(user).then((isNewUser) {
      if (isNewUser) {
        _authRepo.addDataToDb(user).then((value) {
          gotoHomePage();
        });
      } else {
        gotoHomePage();
      }
    });
  }

  void gotoHomePage() async{
    print('Going to home.....');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ChatScreen();
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kColorAsh,
        body: Container(
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            children: [
              Image.asset(
                'assets/images/arm.png',
                width: 200,
              ),
              SizedBox(
                height: 12,
              ),
              Text.rich(
                TextSpan(
                  text: "Welcome to ARM Group Chat\n",
                  style: TextStyle(fontSize: 18, color: kColorDarkBlue, fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(
                      text: (logRegState == LogRegState.LOGIN) ? 'Continue by Signing In to your account':'Continue by creating an account',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    // can add more TextSpans here...
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                    // color: kColorAsh
                    ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: kColorAccent.withOpacity(.6), width: 1)),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      focusNode: emailFieldFocus,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.black, fontSize: 20),
                      cursorColor: Colors.blueGrey,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Colors.black54,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        // prefix: Icon(Icons.email, color: kColorAccent),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 16, bottom: 2, top: 2, right: 16),
                      ),
                    ),
                    Divider(
                      color: kColorAccent,
                      thickness: 1,
                      height: 12,
                    ),
                    TextField(
                      obscureText: true,
                      controller: passwordController,
                      focusNode: passwordFieldFocus,
                      keyboardType: TextInputType.visiblePassword,
                      style: TextStyle(color: Colors.black, fontSize: 20),
                      cursorColor: Colors.blueGrey,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.black54,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        // prefix: Icon(Icons.lock, color: kColorAccent, size: 16,),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 16, bottom: 2, top: 2, right: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _logOrReg,
                      child: Container(
                        alignment: Alignment.center,
                        height: 45,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: kFabGradient,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          (logRegState == LogRegState.LOGIN) ? 'SIGN IN' : "REGISTER",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  InkWell(
                    onTap: _facebookSignIn,
                    child: Image.asset('assets/images/facebook.png', width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  SizedBox(width: 12),
                  InkWell(
                    onTap: _googleSignIn,
                    child: Image.asset('assets/images/google.png', width: 42, height: 42, fit: BoxFit.cover),
                  ),
                ],
              ),
              Divider(
                color: kColorAccent,
                height: 60,
                thickness: 1,
              ),
              Container(
                // margin: EdgeInsets.only(top: 30),
                child: InkWell(
                  onTap: _toggleState,
                  child: Text.rich(
                    TextSpan(
                      text: (logRegState == LogRegState.LOGIN) ? "DON'T HAVE AN ACCOUNT? " : "ALREADY HAVE AN ACCOUNT? ",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                          text: (logRegState == LogRegState.LOGIN) ? 'SIGN UP' : 'LOG IN',
                          style: TextStyle(color: kColorRed.withOpacity(.6)),
                        ),
                        // can add more TextSpans here...
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        // color: kColorAsh
                        ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

enum LogRegState { LOGIN, REGISTER }
