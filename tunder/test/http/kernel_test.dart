import 'dart:math';

import 'package:test/test.dart';
import 'package:tunder/contracts.dart';
import 'package:tunder/http.dart';
import 'package:tunder/tunder.dart';

import '../helpers.dart';

main() {
  group('Kernel', () {
    test('500 status code', () async {
      var app = Application();
      app.singleton(HttpKernelContract, Kernel);
      Route.get('/error', () => throw SomeException('Some Error'));
      await app.serve(port: Random().nextInt(5996) + 4003);

      var response = await get('/error');
      expect(response.statusCode, 500);
      expect(response.body, contains('Some Error'));
    });
  });
}

class SomeException implements Exception {
  final String message;

  const SomeException(this.message);

  @override
  String toString() => message;
}
