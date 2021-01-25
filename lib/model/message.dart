import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

Message messageFromMap(String str) => Message.fromMap(json.decode(str));

String messageToMap(Message data) => json.encode(data.toMap());

class Message {
  String key; //FROM RTDB
  String senderId;
  String type;
  String message;
  int timestamp;
  String photoUrl;

  Message({
    this.key,
    this.senderId,
    this.type,
    this.message,
    this.timestamp,
    this.photoUrl = '',
  });

  Map<String, dynamic> toMap() => {
        "key": key,
        "message": message,
        "senderId": senderId,
        "type": type,
        "timestamp": timestamp,
        "photoUrl": photoUrl,
      };

  // named constructor
  factory Message.fromMap(Map<dynamic, dynamic> json) => Message(
    key: json['key'],
    senderId: json['senderId'],
        type: json['type'],
        message: json['message'],
        timestamp: json['timestamp'],
        photoUrl: json['photoUrl'],
      );
}
