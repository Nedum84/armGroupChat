import 'package:arm_group_chat/model/message.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatRepo{

  var _firebaseChatRef = FirebaseDatabase().reference().child('chats');

  sendMessage(Message message) {
    // _firebaseChatRef.push().set({
    //   "message": _txtCtrl.text,
    //   "timestamp": DateTime.now().millisecondsSinceEpoch
    // });
    _firebaseChatRef.push().set(message.toMap());
  }


  Stream<Event> fetchMessages() => _firebaseChatRef.onValue;

  Future<DataSnapshot> fetchMessages2() => _firebaseChatRef.once();
}