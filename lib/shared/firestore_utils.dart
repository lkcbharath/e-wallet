import 'package:cloud_firestore/cloud_firestore.dart';

void _addTransaction(_transactionObj) {
  CollectionReference dbTransactions =
      Firestore.instance.collection('transactions');
  Firestore.instance.runTransaction((Transaction tx) async {
    await dbTransactions.add(_transactionObj.toJson());
  });
}

Future<int> _getTransactionID() async {
  QuerySnapshot transactions =
      await Firestore.instance.collection('transactions').getDocuments();
  List<DocumentSnapshot> _myDocCount = transactions.documents;
  return _myDocCount.length;
}
