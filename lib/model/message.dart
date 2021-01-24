import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

Message messageFromMap(String str) => Message.fromMap(json.decode(str));

String messageToMap(Message data) => json.encode(data.toMap());

class Message {
  String senderId;
  String receiverId;
  String type;
  String message;
  Timestamp timestamp;
  String photoUrl;

  Message({
    this.senderId,
    this.receiverId,
    this.type,
    this.message,
    this.timestamp,
    this.photoUrl,
  });


  Map<String, dynamic> toMap() =>{
        "message": message,
        "senderId": senderId,
        "receiverId": receiverId,
        "type": type,
        "timestamp": timestamp,
        "photoUrl": photoUrl
  };

  // named constructor
  factory Message.fromMap(Map<String, dynamic> json) => Message(
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        type: json['type'],
        message: json['message'],
        timestamp: json['timestamp'],
        photoUrl: json['photoUrl']
  );
}
