import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:my_finances/model/PersistedPayment.dart';

class HttpService {
  static final String SERVER_IP = "10.0.2.2";
  static final String SERVER_PORT = "8080";
  static final String CONTENT_TYPE = 'application/json; charset=UTF-8';

  static sendToServer(List<PersistedPayment>? allEntries) async {
    return await http.post(
      Uri.parse('http://$SERVER_IP:$SERVER_PORT/'),
      headers: <String, String>{
        'Content-Type': CONTENT_TYPE,
      },
      body: jsonEncode(allEntries),
    );
  }

  static sendToServer1(Map<String, Object> allEntries) async {
    return await http.post(
      Uri.parse('http://$SERVER_IP:$SERVER_PORT/'),
      headers: <String, String>{
        'Content-Type': CONTENT_TYPE,
      },
      body: jsonEncode(allEntries),
    );
  }

  static retrieveDataFrmServerAndClearDB() async {
    var response = await http.get(
      Uri.parse('http://$SERVER_IP:$SERVER_PORT/'),
      headers: <String, String>{
        'Content-Type': CONTENT_TYPE,
      },
    );

    if (response.statusCode == 200) {
      await http.delete(
          Uri.parse('http://$SERVER_IP:$SERVER_PORT/'));
    }

    return jsonDecode(response.body);
  }

}
