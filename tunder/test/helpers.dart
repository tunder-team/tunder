import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/utils.dart';

Future<http.Response> get(
  String uri, {
  headers,
}) =>
    http.get(
      Uri.parse(url(uri)),
      headers: headers,
    );

Future<http.Response> post(
  String uri, {
  headers,
  body,
}) =>
    http.post(
      Uri.parse(url(uri)),
      headers: headers,
      body: body,
    );

Future<http.Response> put(
  String uri, {
  headers,
  body,
}) =>
    http.put(
      Uri.parse(url(uri)),
      headers: headers,
      body: body,
    );

Future<http.Response> delete(
  String uri, {
  headers,
  body,
}) =>
    http.delete(
      Uri.parse(url(uri)),
      headers: headers,
      body: body,
    );

Future<http.Response> patch(
  String uri, {
  headers,
  body,
}) =>
    http.patch(
      Uri.parse(url(uri)),
      headers: headers,
      body: body,
    );

Future<void> assertDatabaseHas(String table, Map<String, dynamic> where) async {
  final query = Query(table);

  where.entries.forEach((entry) {
    query.where(entry.key).equals(entry.value);
  });

  expect(await query.count(), greaterThan(0),
      reason:
          "Database table [$table] doesn't have any records matching $where");
}

Future<void> assertDatabaseDoesntHave(
    String table, Map<String, dynamic> where) async {
  final query = Query(table);

  where.entries.forEach((entry) {
    query.where(entry.key).equals(entry.value);
  });
  final count = await query.count();
  expect(count, 0,
      reason:
          "Database table [$table] shouldn't have records matching $where but found $count record(s)");
}
