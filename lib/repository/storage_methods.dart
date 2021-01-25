import 'dart:io';
import 'package:arm_group_chat/model/message.dart';
import 'package:arm_group_chat/provider/image_upload_provider.dart';
import 'package:arm_group_chat/repository/chat_repo.dart';
import 'package:arm_group_chat/utils/collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

class StorageMethods {

  Reference _storageReference;


  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');

      UploadTask uploadTask = _storageReference.putFile(imageFile);
      String url  = await uploadTask.then((res) async{
        return await res.ref.getDownloadURL();
      });
      return url;
    } catch (e) {
      return null;
    }
  }


  void uploadImage({
    @required File image,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider,
  }) async {
    final Message message = Message();

    // Set some loading value to db and show it to user
    imageUploadProvider.setToLoading();

    // Get url from the image bucket
    String url = await uploadImageToStorage(image);

    // Hide loading
    imageUploadProvider.setToIdle();


    message.senderId = senderId;
    message.type = MESSAGE_TYPE_IMAGE;
    message.message = '';
    message.photoUrl = url;
    message.timestamp = Timestamp.now().microsecondsSinceEpoch;

    ChatRepo.addMessageToDb(message);
  }
}
