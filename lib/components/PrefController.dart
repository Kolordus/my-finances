import 'package:shared_preferences/shared_preferences.dart';


class PrefController {

  static void saveAmountPref(String name, double amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(name, amount.toString());
  }

  static Future<String> getAmountPref(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? amount = prefs.getString(name);

    return amount.toString();
  }

}


