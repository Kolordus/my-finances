import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:my_finances/model/PersistedPayment.dart';

class HttpService {
  static final String PROTCOL = "http://";
  static final String SERVER_IP = "192.168.0.108";
  static final String SERVER_PORT = "8080";
  static final String CONTENT_TYPE = 'application/json; charset=UTF-8';

  static Future<bool> sendToServer(List<PersistedPayment> allEntries) async {
    var isSuccess = false;

    Future<bool> waitFor = timer(2);
    Future postRequest = http.post(
      Uri.parse('$PROTCOL$SERVER_IP:$SERVER_PORT/'),
      headers: <String, String>{
        'Content-Type': CONTENT_TYPE,
      },
      body: jsonEncode(allEntries),
    );

    List<Future> futures = [waitFor, postRequest];

    try {
      var firstToBeResolved = await Future.any(futures);
      if (firstToBeResolved is http.Response) {
        isSuccess = true;
      }
    } on Exception catch (_) {

    }

    return isSuccess;
  }

  static retrieveDataFromServerAndClearDB() async {
    dynamic response;
    Future<bool> waitFor = timer(2);
    Future getRequest = http.get(
      Uri.parse('$PROTCOL$SERVER_IP:$SERVER_PORT/'),
      headers: <String, String>{
        'Content-Type': CONTENT_TYPE,
      },
    );

    List<Future> futures = [waitFor, getRequest];

    try {
      var firstToBeResolved = await Future.any(futures);
      if (firstToBeResolved is http.Response) {

        response = jsonDecode(firstToBeResolved.body);

        await http.delete(
            Uri.parse('$PROTCOL$SERVER_IP:$SERVER_PORT/'));

      }
    } on Exception catch (_) {

    }

    return response;
  }


  static Future<bool> timer(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
    return false;
  }

}
