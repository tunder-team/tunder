import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:tunder/tunder.dart';

main() {
  HttpServer? server;
  String? baseUrl;

  setUpAll(() async {
    server = await createServer();
    baseUrl = 'http://${server!.address.host}:${server!.port}';
    handleRequest(server!);
  });

  tearDownAll(() async {
    await server!.close(force: true);
    server = null;
    baseUrl = null;
  });

  test('server', () async {
    var response = await get(Uri.parse(baseUrl!));
    expect(response.body, 'it worked');
  });

  test('Application.serve', () async {
    server!.close(force: true);
    server = await Application().serve(port: 1234);
    var port = server!.port;
    expect(server, TypeMatcher<HttpServer>());
    expect(port, 1234);
    var server2 = await Application().serve(port: 1235);

    expect(port, isNot(server2.port));
    expect(() => server!.port, throwsA(TypeMatcher<Exception>()));
  });
}

createServer() async =>
    await HttpServer.bind(InternetAddress.loopbackIPv4, 9123);

handleRequest(HttpServer server) async {
  await for (var request in server) {
    request.response.write('it worked');
    request.response.close();
  }
}
