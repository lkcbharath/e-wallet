import 'package:monopoly_atm/models/user.dart';
import 'package:monopoly_atm/screens/authenticate/authenticate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monopoly_atm/main.dart';
import 'package:monopoly_atm/screens/tabs/info_page.dart';
import 'package:monopoly_atm/screens/tabs/payment_page.dart';
import 'package:monopoly_atm/screens/tabs/profile_page.dart';
import 'package:monopoly_atm/screens/tabs/transactions_page.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return MaterialApp(
      title: 'Monopoly Money',
      theme: ThemeData(primarySwatch: Colors.red, accentColor: Colors.green),
      home: (user == null)
          ? Authenticate()
          : DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.attach_money)),
                Tab(icon: Icon(Icons.person)),
                Tab(icon: Icon(Icons.view_list)),
                Tab(icon: Icon(Icons.info)),
              ],
            ),
            title: Text('Monopoly Money'),
          ),
          body: TabBarView(
            children: [
              const PaymentPage(),
              const ProfilePage(),
              const TransactionsPage(),
              const InfoPage(),
            ],
          ),
        ),
      ),
    );
  }
}
