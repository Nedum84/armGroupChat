import 'package:arm_group_chat/model/message.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatRepo{
  static final DatabaseReference firebaseChatRef = FirebaseDatabase().reference().child('chats');

  static Future<void> addMessageToDb(Message message) => firebaseChatRef.push().set(message.toMap());
  // static Future<void> addMessageToDb(Message message) => firebaseChatRef.set(message.toMap());

  Stream<Event> fetchMessages() => firebaseChatRef.onValue;

  Future<DataSnapshot> fetchMessages2() => firebaseChatRef.once();
}