import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

class Utilities {

  // this is new
  static Future<File> pickImage({@required ImageSource source}) async {
    var pickedImage = await ImagePicker().getImage(source: source);
    if (pickedImage != null) {
      var imgFile = File(pickedImage.path);
      return await compressImage(imgFile);
    } else {
      return null;
    }
  }

  static Future<File> compressImage(File imageToCompress) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    String rand = genRandString();

    String targetPath = '$path/arm_$rand.jpg';
    var result = await FlutterImageCompress.compressAndGetFile(
      imageToCompress.absolute.path, targetPath,
      quality: 75,
        // rotate: 180,
        // rotate: 0,
      format: CompressFormat.jpeg
    );

    return result;
  }

  //CALCULATES THE CURRENT TIME AND DISPLAYS ACCORDINGLY
  static String formatDate(int dateInt) {
    return formatDateString3(dateInt);
  }

  static String formatDateString(int dateInt) {
    DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(dateInt);
    // var formatter = DateFormat('yMMMd');
    var formatter = DateFormat.yMMMd();
    return formatter.format(dateTime);
  }

  static String formatDateString2(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    var formatter = DateFormat('dd/MM/yy');
    return formatter.format(dateTime);
  }

  static String formatDateString3(int date) {
    DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(date);
    var formatter = DateFormat('MMM d, H:m a');//MMM-> Dec, MMMM-> December, h->Hour(1-12), H->Hour(1-24), m-Minute, a-> AM/PM
    // var formatter = DateFormat('MMM d,  yyyy');
    return formatter.format(dateTime);
  }

  static String genRandString({int length = 15}) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

    return getRandomString(length);
  }

}