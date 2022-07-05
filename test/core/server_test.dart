import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

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
}

createServer() async {
  return await HttpServer.bind(InternetAddress.loopbackIPv4, 9123);
}

handleRequest(HttpServer server) async {
  await for (var request in server) {
    request.response.write('it worked');
    request.response.close();
  }
}
