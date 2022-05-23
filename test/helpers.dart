import 'package:http/http.dart' as http;
import 'package:tunder/utils.dart';

Future<http.Response> get(String uri, {headers}) {
  return http.get(Uri.parse(url(uri)), headers: headers);
}

Future<http.Response> put(String uri, {headers, body}) {
  return http.put(Uri.parse(url(uri)), headers: headers, body: body);
}

Future<http.Response> patch(String uri, {headers, body}) {
  return http.patch(Uri.parse(url(uri)), headers: headers, body: body);
}

Future<http.Response> post(String uri, {headers, body}) {
  return http.post(Uri.parse(url(uri)), headers: headers, body: body);
}

Future<http.Response> delete(String uri, {headers, body}) {
  return http.delete(Uri.parse(url(uri)), headers: headers, body: body);
}
