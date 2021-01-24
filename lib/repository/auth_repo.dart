import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arm_group_chat/utils/collections.dart';
import 'package:arm_group_chat/model/app_user.dart';
import 'package:arm_group_chat/screen/login/login_register.dart';


class AuthRepo {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FacebookLogin _fbLogin = FacebookLogin();

  static final DatabaseReference _firebaseUserRef = FirebaseDatabase().reference().child('users');
  // final _firebaseUserRef = FirebaseDatabase.instance.reference();


  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = await _auth.currentUser;
    return currentUser;
  }

  Future<AppUser> getUserDetails({String userId}) async {//if empty return current user id or use the specified user id to fetch the details
    String uid;
    if(userId==null||userId.isEmpty){
      uid = (await getCurrentUser()).uid;
    }else{
      uid = userId;
    }


    DataSnapshot documentSnapshot = await _firebaseUserRef.child(uid).once();
    return AppUser.fromMap(documentSnapshot.value);
  }


  Future<User> googleSignIn() async {
    try {
      GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication _signInAuthentication =
      await _signInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: _signInAuthentication.accessToken,
          idToken: _signInAuthentication.idToken);

      User user = (await _auth.signInWithCredential(credential)).user;
      return user;
    } catch (e) {
      print("Auth methods error");
      print(e);
      return null;
    }
  }

  Future<User> facebookSignIn() async {
    try {
      final FacebookLoginResult facebookLoginResult = await _fbLogin.logIn(
          ['email']);
      User fbUser;
      switch (facebookLoginResult.status) {
        case FacebookLoginStatus.loggedIn:
          FacebookAccessToken facebookAccessToken = facebookLoginResult
              .accessToken;
          AuthCredential authCredential = FacebookAuthProvider.credential(
              facebookAccessToken.token);
          fbUser =
              (await _auth.signInWithCredential(authCredential))
                  .user;

          break;
        case FacebookLoginStatus.cancelledByUser:
          print('Facebook login cancelled');
          fbUser = null;
          break;
        case FacebookLoginStatus.error:
          print('There was an error while trying to log in. Try again' +
              facebookLoginResult.errorMessage);
          fbUser = null;
          break;
      }


      return fbUser;
    } catch (e) {
      print("Auth methods error");
      print(e);
      return null;
    }
  }



  Future<bool> authenticateUser(User user) async {
    DataSnapshot result = await _firebaseUserRef
        .child(user.uid)
        .once();
    // final List<DataSnapshot> docs = result.value;
    //if user is registered then length of list > 0 or else less than 0
    // return docs.length == 0 ? true : false;
    return result.value == null ? true : false;
  }

  Future<void> addDataToDb(User currentUser) async {

    AppUser appUser = AppUser(
        uid: currentUser.uid,
        email: currentUser.email,
        name: currentUser.displayName,
        dateRegistered: DateTime.now().millisecondsSinceEpoch
    );

    _firebaseUserRef
        .child(currentUser.uid)
        .set(appUser.toMap(appUser));

  }


  Future<void> updateUserDetailsMultiple({@required Map<String, dynamic> userDetailMap}) async {
    _firebaseUserRef
        .child(_auth.currentUser.uid)
        .update(userDetailMap).then((value) => print('value')).catchError((er) => print(er));
  }

  Future<List<AppUser>> fetchAllUsers(User currentUser) async {
    List<AppUser> userList = List<AppUser>();

    DataSnapshot querySnapshot = await _firebaseUserRef.once();

    for (var i = 0; i < querySnapshot.value.length; i++) {
      if (querySnapshot.value[i].id != currentUser.uid) {
        userList.add(AppUser.fromMap(querySnapshot.value[i].data()));
      }
    }
    return userList;
  }

  Future<bool> signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      // _gotoLoginPage(context);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
  _gotoLoginPage(BuildContext context){
    Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return LoginRegister();
        }, transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        }),(Route route) => false);
  }

}


