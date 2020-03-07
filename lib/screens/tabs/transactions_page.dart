import 'package:monopoly_atm/main.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({Key key, this.title}) : super(key: key);

  final String title;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Container(
        child: Card(
            child: Ink(
                decoration: new BoxDecoration(
                  color: Colors.white,
                ),
                child: ListTile(
                    leading: Icon(Icons.attach_money),
                    title: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.body1,
                        children: [
                          TextSpan(text: document['sender_name']),
                          WidgetSpan(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Icon(Icons.arrow_forward),
                            ),
                          ),
                          TextSpan(text: document['receiver_name']),
                        ],
                      ),
                    ),
                    trailing: Text(document['amount'].toString())))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: Firestore.instance.collection('transactions').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Loading...');

              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) =>
                    _buildListItem(context, snapshot.data.documents[index]),
              );
            }));
  }
}
