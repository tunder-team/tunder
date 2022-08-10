import 'package:tunder/http.dart';
import 'package:tunder/utils.dart';
import 'package:test/test.dart';

import '../feature.dart';
import '../helpers.dart' as http;

main() {
  feature();

  group("Request.get('param') from GET requests", () {
    late Router route;

    setUp(() {
      route = app(Router);
      route.flush();
      route.get('/users/{user}/posts', (Request request) {
        return request.get('param');
      });
    });

    test('accepts single value', () async {
      var response = await http.get('users/12/posts?param=Marco');
      expect(response.body, 'Marco');
    });

    test('accepts array separated by comma', () async {
      route.get('another/path', (Request request) {
        expect(request.get('param'), ['one', 'two', 'three']);
      });
      await http.get('another/path?param=one,two,three');
    });

    test('casts integer values', () async {
      route.get('another/path', (Request request) {
        assert(request.get('param') == 12);
        return 'ok';
      });
      var response = await http.get('another/path?param=12');
      expect(response.body, 'ok');
    });

    test('casts double values', () async {
      route.get('another/path', (Request request) {
        assert(request.get('param') == 12.2);
        return 'ok';
      });
      var response = await http.get('another/path?param=12.2');
      expect(response.body, 'ok');
    });

    test('casts array of numbers', () async {
      route.get('another/path', (Request request) {
        assert(ListEquality().equals(request.get('param'), [1, 2.2, 3]));
        return 'ok';
      });
      var response = await http.get('another/path?param=1,2.2,3');
      expect(response.body, 'ok');
    });

    test('casts boolean values (true)', () async {
      route.get('another/path', (Request request) {
        assert(request.get('param') == true);
        return 'ok';
      });
      var response = await http.get('another/path?param=true');
      expect(response.body, 'ok');
    });

    test('casts boolean values (false)', () async {
      route.get('another/path', (Request request) {
        assert(request.get('param') == false);
        return 'ok';
      });
      var response = await http.get('another/path?param=false');
      expect(response.body, 'ok');
    });

    test("casts 'undefined', 'null' and '' to null", () async {
      route.get('another/path', (Request request) {
        assert(request.get('param') == null);
        return 'ok';
      });
      var response = await http.get('another/path?param=');
      expect(response.body, 'ok');
      response = await http.get('another/path?param=null');
      expect(response.body, 'ok');
      response = await http.get('another/path?param=undefined');
      expect(response.body, 'ok');
    });
  });
}
