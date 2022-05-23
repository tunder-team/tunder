import 'package:http/http.dart' as http;
import 'package:tunder/utils.dart';

class Http {
  static Future<http.Response> get(String uri, {headers}) {
    return http.get(Uri.parse(url(uri)), headers: headers);
  }
}
