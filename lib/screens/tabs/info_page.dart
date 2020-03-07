import 'package:monopoly_atm/main.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          child: Container(
            width: 300,
            height: 100,
            child: Text('Built by Bharath Adikar: lkcbharath@gmail.com'),
          ),
        ),
      ),
    );
  }
}