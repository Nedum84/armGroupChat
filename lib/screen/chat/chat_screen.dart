import 'dart:io';
import 'package:arm_group_chat/enum/image_view_state.dart';
import 'package:arm_group_chat/model/app_user.dart';
import 'package:arm_group_chat/model/message.dart';
import 'package:arm_group_chat/provider/image_upload_provider.dart';
import 'package:arm_group_chat/repository/auth_repo.dart';
import 'package:arm_group_chat/repository/chat_repo.dart';
import 'package:arm_group_chat/repository/storage_methods.dart';
import 'package:arm_group_chat/utils/alert_utils.dart';
import 'package:arm_group_chat/utils/collections.dart';
import 'package:arm_group_chat/utils/colors.dart';
import 'package:arm_group_chat/utils/utilities.dart';
import 'package:arm_group_chat/widgets/alert_dialog/close_app_warning.dart';
import 'package:arm_group_chat/widgets/alert_dialog/log_out_overlay.dart';
import 'package:arm_group_chat/widgets/cached_image.dart';
import 'package:arm_group_chat/widgets/choose_image_from.dart';
import 'package:arm_group_chat/widgets/view_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ImageUploadProvider _imageUploadProvider;

  final StorageMethods _storageMethods = StorageMethods();
  final AuthRepo _authRepo = AuthRepo();

  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();

  AppUser sender;
  bool isWriting = false;

  @override
  void initState() {
    super.initState();
  }

  showKeyboard() => textFieldFocus.requestFocus();
  hideKeyboard() => textFieldFocus.unfocus();

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        _closeAppDialog();
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Color(0xffEEF2F4),
        appBar: customAppBar(context),
        body: FutureBuilder<AppUser>(
            future: _authRepo.getUserDetails(),
            builder: (context, snapshot) {
              if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
              sender = snapshot.data;
              return Column(
                children: <Widget>[
                  Flexible(
                    child: messageList(),
                  ),
                  _imageUploadProvider.getImageViewState == ImageViewState.LOADING
                      ? Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: 15),
                    child: CircularProgressIndicator(),
                  )
                      : Container(),
                  chatControls(),
                  // showEmojiPicker ? Container(child: emojiContainer()) : Container(),
                ],
              );
            }
        ),
      ),
    );
  }

  Widget messageList() {
    return StreamBuilder<Event>(
      stream: ChatRepo.firebaseChatRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.snapshot.value==null) {
            return Center(
              child: Text(
                "No message",
              ),
            );
          }

          // final messages = snapshot.data.snapshot.value.reversed;
          final result = snapshot.data.snapshot.value;
          List messages = [];
          result.forEach((index, data) => messages.add({"key": index, ...data}));

          // messages = messages.reversed;

          // messages..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));//asc
          messages..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));//asc

          return ListView.builder(
            padding: EdgeInsets.all(8),
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return messageItem(Message.fromMap(messages[index]));
            },
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget messageItem(Message message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Container(
        alignment: message.senderId == sender.uid ? Alignment.centerRight : Alignment.centerLeft,
        child: message.senderId == sender.uid ? senderLayout(message) : receiverLayout(message),
      ),
    );
  }

  getMessage(Message message) {
    return message.type != MESSAGE_TYPE_IMAGE
        ? Text(
      message.message,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16.0,
      ),
    )
        : message.photoUrl != null
        ? GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewImage(imageUrl: message.photoUrl))),
      child: CachedImage(
        message.photoUrl,
        height: 250,
        width: 250,
        radius: 10,
      ),
    )
        : Text("Invalid Url");
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: BoxDecoration(
          color: kColorPrimary.withOpacity(.2),
          border: Border.all(color: Colors.blueGrey.withOpacity(.2), width: 1),
          borderRadius: BorderRadius.only(
            topLeft: messageRadius,
            topRight: messageRadius,
            bottomLeft: messageRadius,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            getMessage(message),
            SizedBox(
              height: 2,
            ),
            Text(
              // '${sender.name} ⦿ ${Utilities.formatDate(message.timestamp)}',
              '${Utilities.formatDate(message.timestamp)}',
              style: TextStyle(fontSize: 10, color: Colors.black26, fontStyle: FontStyle.italic),
            )
          ],
        ));
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: BoxDecoration(
          color: Colors.white70.withOpacity(.4),
          border: Border.all(color: Colors.blueGrey.withOpacity(.2), width: 1),
          borderRadius: BorderRadius.only(
            bottomRight: messageRadius,
            topRight: messageRadius,
            bottomLeft: messageRadius,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getMessage(message),
            SizedBox(
              height: 2,
            ),
            FutureBuilder<AppUser>(
              future: _authRepo.getUserDetails(userId: message.senderId),
              builder: (context, snapshot) {
                if(!snapshot.hasData) return Container();
                return Text(
                  '${snapshot.data.name} ⦿ ${Utilities.formatDate(message.timestamp)}',
                  // Utilities.formatDate(message.timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.black26, fontStyle: FontStyle.italic),
                );
              }
            )
          ],
        ));
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    _showFileChooser() {
      hideKeyboard();

      showModalBottomSheet(
          context: context,
          builder: (builder) {
            return ChooseImageFrom(
              imageSource: (source) => pickImage(source: source),
            );
          });
    }

    sendMessage() {
      var text = textFieldController.text;

      Message _message = Message(
        senderId: sender.uid,
        message: text,
        timestamp: Timestamp.now().microsecondsSinceEpoch,
        type: MESSAGE_TYPE_TEXT,
      );

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";

      ChatRepo.addMessageToDb(_message);
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 4, bottom: 4, right: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textFieldController,
                  focusNode: textFieldFocus,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(
                    color: Colors.blueGrey,
                  ),
                  onChanged: (val) {
                    (val.length > 0 && val.trim() != "") ? setWritingTo(true) : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: kColorAshLight2,
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          isWriting
              ? Container()
              : IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () => _showFileChooser(),
                  icon: Icon(Icons.add_a_photo_sharp, color: Colors.blueGrey.withOpacity(.8)),
                ),
          SizedBox(
            width: 5,
          ),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(gradient: kFabGradient, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 18,
                      color: Colors.white,
                    ),
                    onPressed: () => sendMessage(),
                  ))
              : Container()
        ],
      ),
    );
  }

  AppBar customAppBar(context) {
    return AppBar(
      backgroundColor: Colors.white,
      shadowColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.blueGrey,
        ),
        onPressed: _closeAppDialog,
      ),
      centerTitle: false,
      title: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: kColorAsh,
            child: Icon(
              Icons.people_alt_rounded,
              color: kColorPrimary.withOpacity(.5),
            ),
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            'ARM Group Chat',
            style: TextStyle(color: Colors.blueGrey, fontSize: 16),
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.power_settings_new,
            color: Colors.blueGrey,
          ),
          onPressed: _logOutDialog,
        )
      ],
    );
  }


  void pickImage({@required ImageSource source}) async {
    File selectedImage = await Utilities.pickImage(source: source);
    _storageMethods.uploadImage(image: selectedImage, senderId: sender.uid, imageUploadProvider: _imageUploadProvider);
  }

  _logOutDialog() async {
    hideKeyboard();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LogoutOverlay(),
    );
  }

  _closeAppDialog() async {
    hideKeyboard();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
          onWillPop: () => Future.value(false),
          child: CloseAppWarning()),
    );
  }
}

