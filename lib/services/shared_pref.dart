import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
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
}
