import 'dart:math';

import 'package:dotenv/dotenv.dart';
import 'package:tunder/contracts.dart';
import 'package:tunder/http.dart';
import 'package:tunder/tunder.dart';
import 'package:test/test.dart';

feature() {
  DotEnv().load(['.env', '.env.test']);
  late Application app;

  setUpAll(() async {
    var port = Random().nextInt(5996) + 4003;
    app = Application();
    await app.serve(port: port);

    app.singleton(HttpKernelContract, Kernel(app, app.get(Router)));
  });
}

Matcher toThrow(Type error, String message) {
  return throwsA(
    predicate(
      (e) => e.runtimeType == error && e.toString().contains(message),
      "${error.toString()} with '$message'",
    ),
  );
}
