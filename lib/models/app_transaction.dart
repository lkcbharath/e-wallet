import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppTransaction {

  final int amount;
  final int receiver_id;
  final String receiver_name;
  final int sender_id;
  final String sender_name;
  final Timestamp timestamp;
  final int transaction_id;

  AppTransaction({
    @required this.amount,
    @required this.receiver_id,
    @required this.receiver_name,
    @required this.sender_id,
    @required this.sender_name,
    @required this.timestamp,
    @required this.transaction_id
  });

  Map<String, dynamic> toJson() =>
      {
        'amount': amount,
        'receiver_id': receiver_id,
        'receiver_name': receiver_name,
        'sender_id': sender_id,
        'sender_name': sender_name,
        'timestamp': timestamp,
        'transaction_id': transaction_id,
      };
}