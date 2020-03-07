import 'package:monopoly_atm/main.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({Key key, this.title}) : super(key: key);

  final String title;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document,
      DocumentSnapshot documentOnDevice) {
    Color color = Colors.white;
    if (document['id'] == documentOnDevice['id']) {
      color = Colors.green;
    }

    documentOnDevice.reference.updateData({'chosen': true});

    return Container(
        child: Card(
            child: Ink(
                decoration: new BoxDecoration(
                  color: color,
                ),
                child: ListTile(
                  enabled: !(document['id'] == documentOnDevice['id']),
                  leading: Icon(Icons.account_balance_wallet),
                  title: Text(document['name']),
                  trailing: Text(document['money'].toString()),
                  onTap: () {
                    dynamic money = '';
                    if (document['id'] == documentOnDevice['id']) {
                      return showDialog<String>(
                          context: context,
                          barrierDismissible: false,
                          // dialog is dismissible with a tap on the barrier
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('This is your balance!'),
                              actions: <Widget>[
                                RaisedButton(
                                  color: Colors.green,
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    }
                    return showDialog<String>(
                      context: context,
                      barrierDismissible: false,
                      // dialog is dismissible with a tap on the barrier
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Enter amount to transfer'),
                          content: new Row(
                            children: <Widget>[
                              new Expanded(
                                  child: new TextField(
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                decoration:
                                    new InputDecoration(hintText: 'eg. 200'),
                                onChanged: (value) {
                                  money = value;
                                },
                              ))
                            ],
                          ),
                          actions: <Widget>[
                            RaisedButton(
                              color: Colors.green,
                              child: Text('Transfer'),
                              onPressed: () async {
                                if (_isNumeric(money)) {
                                  var transaction_id =
                                      await _getTransactionID();

                                  document.reference.updateData({
                                    'money':
                                        document['money'] + int.parse(money)
                                  });
                                  documentOnDevice.reference.updateData({
                                    'money': documentOnDevice['money'] -
                                        int.parse(money)
                                  });

                                  var appTransactionObj = new AppTransaction(
                                      amount: int.parse(money),
                                      receiver_id: document['id'],
                                      receiver_name: document['name'],
                                      sender_id: documentOnDevice["id"],
                                      sender_name: documentOnDevice["name"],
                                      timestamp: Timestamp.now(),
                                      transaction_id: transaction_id);
                                  _addTransaction(appTransactionObj);

                                  Navigator.of(context).pop();
                                } else {
                                  Toast.show(
                                      "Enter a valid amount to transfer!",
                                      context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.TOP);
                                }
                              },
                            ),
                            RaisedButton(
                              color: Colors.green,
                              child: Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getEmailOnDevice(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) return Text('Loading...');
          String emailOnDevice = snapshot.data;
          return Scaffold(
              body: StreamBuilder(
                  stream: Firestore.instance.collection('players').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text('Loading...');

                    DocumentSnapshot documentOnDevice = snapshot.data.documents
                        .firstWhere((doc) => doc['email'] == emailOnDevice,
                            orElse: () => null);
                    return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) => _buildListItem(context,
                          snapshot.data.documents[index], documentOnDevice),
                    );
                  }));
        });
  }
}

Future<String> _getEmailOnDevice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String email = '';
  if (!prefs.containsKey('email')) {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    email = user.email;
    _setEmailOnDevice(email);
  } else {
    email = prefs.getString('email');
  }
  return email;
}

_setEmailOnDevice(email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('email', email);
}

Future<int> _getTransactionID() async {
  QuerySnapshot transactions =
      await Firestore.instance.collection('transactions').getDocuments();
  List<DocumentSnapshot> _myDocCount = transactions.documents;
  return _myDocCount.length;
}

void _addTransaction(_transactionObj) {
  CollectionReference dbTransactions =
  Firestore.instance.collection('transactions');
  Firestore.instance.runTransaction((Transaction tx) async {
    await dbTransactions.add(_transactionObj.toJson());
  });
}

bool _isNumeric(String s) {
  if (s == null || s == '') {
    return false;
  }
  return int.parse(s) != null;
}