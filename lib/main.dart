import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:monopoly_atm/screens/authenticate/authenticate.dart';
import 'package:monopoly_atm/models/user.dart';
import 'package:monopoly_atm/screens/wrapper.dart';
import 'package:monopoly_atm/services/auth.dart';

export 'package:flutter/material.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:toast/toast.dart';
export 'package:tuple/tuple.dart';
export 'package:monopoly_atm/models/user.dart';
export 'package:monopoly_atm/models/app_transaction.dart';

void main() => runApp(MyApp());

//CollectionReference dbTransactions = Firestore.instance.collection('transactions');

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
