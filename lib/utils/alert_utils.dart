import 'package:flutter/material.dart';
import 'package:arm_group_chat/utils/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';



class AlertUtils{

  static void alert(String content, {@required BuildContext context, String title}){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: (title!="")?Text(title): Container(),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }


  static void toast(String content, {ToastGravity gravity = ToastGravity.BOTTOM, Toast tLength = Toast.LENGTH_SHORT} ){
    Fluttertoast.showToast(
        msg: content,
        toastLength: tLength,
        gravity: gravity,
        timeInSecForIosWeb: 1,
        backgroundColor: kColorPrimary,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }


}