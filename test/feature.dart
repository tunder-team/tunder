import 'dart:io';
import 'dart:math';

import 'package:dotenv/dotenv.dart';
import 'package:tunder/contracts.dart';
import 'package:tunder/http.dart';
import 'package:tunder/tunder.dart';
import 'package:test/test.dart';

feature() {
  final DotEnv dotenv = DotEnv();
  dotenv.load();
  HttpServer? server;
  String? baseUrl;
  late Application app;

  setUpAll(() async {
    var port = Random().nextInt(5996) + 4003;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    baseUrl = 'http://${server!.address.host}:${server!.port}';
    app = new Application(baseUrl: baseUrl);

    app.singleton(HttpKernelContract, Kernel(app, app.get(Router)));

    handleRequest(app, server!);
  });

  tearDownAll(() async {
    await server!.close(force: true);
    server = null;
    baseUrl = null;
  });
}

handleRequest(Application app, HttpServer server) async {
  await for (var request in server) {
    app.handleRequest(request);
  }
}

Matcher toThrow(Type error, String message) {
  return throwsA(
    predicate(
      (e) => e.runtimeType == error && e.toString().contains(message),
      "${error.toString()} with '$message'",
    ),
  );
}
