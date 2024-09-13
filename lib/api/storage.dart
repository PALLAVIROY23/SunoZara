import 'package:shared_preferences/shared_preferences.dart';

class DataStorage {
  static setData(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static getData(String key) {
    String data = "";
    getSynData(key).then((datax) {
      data = datax;
      // //print(datax);
    });
    return data;
  }

  static getSynData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String x = prefs.getString(key).toString();

    return x;
  }
}
