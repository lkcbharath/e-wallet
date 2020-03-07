import 'package:monopoly_atm/main.dart';

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
  String emailOnDevice = '';
//  Future<FirebaseUser> user = getUser();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getEmailOnDevice(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) return Text('Loading...');
          emailOnDevice = snapshot.data;
          String password = '';
          String amount = '';
          return Scaffold(
              body: StreamBuilder(
                  stream: Firestore.instance.collection('players').where("email", isEqualTo: emailOnDevice).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text('Loading...');
                    List<Tuple2<String, bool>> emailsWithSelection = snapshot
                        .data.documents
                        .map<Tuple2<String, bool>>((document) =>
                            Tuple2<String, bool>(
                                document['email'].toString(),
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
                            value: emailOnDevice,
                            onChanged: (String newValue) {
                              DocumentSnapshot documentNew = snapshot
                                  .data.documents
                                  .firstWhere((doc) => doc['email'] == newValue,
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
                                          (doc) => doc['email'] == emailOnDevice,
                                          orElse: () => null);
                                  documentOnDevice.reference
                                      .updateData({'chosen': false});
                                  documentNew.reference
                                      .updateData({'chosen': true});
                                  _setEmailOnDevice(newValue);
                                });
                              }
                            },
                            items: emailsWithSelection
                                .map<DropdownMenuItem<String>>((Tuple2 value) {
                              return DropdownMenuItem<String>(
                                  value: value.item1,
                                  child: Text(value.item1,
                                      style: TextStyle(
                                          color: ((emailOnDevice == value.item1)
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
                                                    (document) => (int.parse(
                                                                document[
                                                                        'id']
                                                                    .toString()) ==
                                                            0)
                                                        ? document.reference
                                                            .updateData({
                                                            'money': 100000
                                                          })
                                                        : document.reference
                                                            .updateData({
                                                            'money': int.parse(
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

bool _isNumeric(String s) {
  if (s == null || s == '') {
    return false;
  }
  return int.parse(s) != null;
}



