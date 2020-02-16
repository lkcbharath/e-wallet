import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:tuple/tuple.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monopoly Money',
      theme: ThemeData(primarySwatch: Colors.red, accentColor: Colors.green),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.attach_money)),
                Tab(icon: Icon(Icons.person)),
              ],
            ),
            title: Text('Monopoly Money'),
          ),
          body: TabBarView(
            children: [
              const TransactionsPage(),
              const ProfilePage(),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({Key key, this.title}) : super(key: key);

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
                              onPressed: () {
                                if (_isNumeric(money)) {
                                  document.reference.updateData({
                                    'money':
                                        document['money'] + int.parse(money)
                                  });
                                  documentOnDevice.reference.updateData({
                                    'money': documentOnDevice['money'] -
                                        int.parse(money)
                                  });
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
        future: _getNameOnDevice(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) return Text('Loading...');
          String nameOnDevice = snapshot.data;
          return Scaffold(
              body: StreamBuilder(
                  stream: Firestore.instance.collection('players').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text('Loading...');

                    DocumentSnapshot documentOnDevice = snapshot.data.documents
                        .firstWhere((doc) => doc['name'] == nameOnDevice,
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return ProfileDropdownWidget();
  }
}

class ProfileDropdownWidget extends StatefulWidget {
  @override
  _ProfileDropdownWidgetState createState() => _ProfileDropdownWidgetState();
}

class _ProfileDropdownWidgetState extends State<ProfileDropdownWidget> {
  String nameOnDevice = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getNameOnDevice(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) return Text('Loading...');
          nameOnDevice = snapshot.data;
          String password = '';
          String amount = '';
          return Scaffold(
              body: StreamBuilder(
                  stream: Firestore.instance.collection('players').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text('Loading...');
                    List<Tuple2<String, bool>> namesWithSelection = snapshot
                        .data.documents
                        .map<Tuple2<String, bool>>((document) =>
                            Tuple2<String, bool>(
                                document['name'].toString(),
                                document['chosen'].toString().toLowerCase() ==
                                    'true'))
                        .toList();
                    return Container(
                        child: Center(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                          Text("Select a user"),
                          SizedBox(
                            height: 20.0,
                          ),
                          DropdownButton<String>(
                            value: nameOnDevice,
                            onChanged: (String newValue) {
                              DocumentSnapshot documentNew = snapshot
                                  .data.documents
                                  .firstWhere((doc) => doc['name'] == newValue,
                                      orElse: () => null);
                              if (documentNew['chosen']
                                      .toString()
                                      .toLowerCase() ==
                                  'true') {
                                Toast.show(
                                    "You cannot choose this user!", context,
                                    duration: Toast.LENGTH_SHORT,
                                    gravity: Toast.TOP);
                              } else {
                                setState(() {
                                  DocumentSnapshot documentOnDevice =
                                      snapshot.data.documents.firstWhere(
                                          (doc) => doc['name'] == nameOnDevice,
                                          orElse: () => null);
                                  documentOnDevice.reference
                                      .updateData({'chosen': false});
                                  documentNew.reference
                                      .updateData({'chosen': true});
                                  _setNameOnDevice(newValue);
                                });
                              }
                            },
                            items: namesWithSelection
                                .map<DropdownMenuItem<String>>((Tuple2 value) {
                              return DropdownMenuItem<String>(
                                  value: value.item1,
                                  child: Text(value.item1,
                                      style: TextStyle(
                                          color: ((nameOnDevice == value.item1)
                                              ? Colors.green
                                              : (value.item2
                                                  ? Colors.red
                                                  : Colors.yellow)))));
                            }).toList(),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          RaisedButton(
                            color: Colors.green,
                            child: Text('Reset Balance'),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Reset Balance'),
                                      content: new Column(
                                        children: <Widget>[
                                          Text('Enter password:'),
                                          new Expanded(
                                              child: new TextField(
                                            autofocus: true,
                                            decoration: new InputDecoration(
                                                hintText: 'eg. abc'),
                                            onChanged: (value) {
                                              password = value;
                                            },
                                          )),
                                          Text(
                                              'Enter amount to reset all players to (Banker gets 100000):'),
                                          new Expanded(
                                              child: new TextField(
                                            autofocus: true,
                                            decoration: new InputDecoration(
                                                hintText: 'eg. 1500'),
                                            onChanged: (value) {
                                              amount = value;
                                            },
                                          )),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        RaisedButton(
                                            color: Colors.green,
                                            child: Text('Reset'),
                                            onPressed: () {
                                              if ((password == '123987') &&
                                                  (_isNumeric(amount))) {
                                                snapshot.data.documents.forEach(
                                                    (document) =>
                                                        (int.parse(document['id'].toString()) == 0)
                                                            ? document.reference
                                                                .updateData({
                                                                'money': 100000
                                                              })
                                                            : document.reference
                                                                .updateData({
                                                                'money':
                                                                    int.parse(
                                                                        amount)
                                                              }));

                                                Navigator.of(context).pop();
                                              } else {
                                                String msg = "";
                                                if (password != '123987')
                                                  msg +=
                                                      "Enter the correct password!";
                                                if (!_isNumeric(amount))
                                                  msg +=
                                                      " Enter a valid amount!";
                                                Toast.show(msg, context,
                                                    duration:
                                                        Toast.LENGTH_SHORT,
                                                    gravity: Toast.TOP);
                                              }
                                            }),
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
                            },
                          )
                        ])));
                  }));
        });
  }
}

Future<String> _getNameOnDevice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String name = '';
  if (!prefs.containsKey('name')) {
    name = 'Banker';
    _setNameOnDevice(name);
  } else {
    name = prefs.getString('name');
  }
  return name;
}

_setNameOnDevice(name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('name', name);
}

bool _isNumeric(String s) {
  if(s == null || s == '') {
    return false;
  }
  return int.parse(s) != null;
}