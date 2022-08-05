import 'package:test/test.dart';
import 'package:tunder/http.dart';
import 'package:tunder/src/http/route_options.dart';
import 'package:tunder/utils.dart';

import '../feature.dart';
import '../helpers.dart';

main() {
  feature();
  group('Route static method', () {
    test('Route.get()', () async {
      Route.get('get', () => 'get');
      final response = await get('/get');
      expect(response.statusCode, 200);
      expect(response.body, 'get');
    });

    test('Route.post()', () async {
      Route.post('post', () => 'post');
      final response = await post('/post');
      expect(response.statusCode, 200);
      expect(response.body, 'post');
    });

    test('Route.put()', () async {
      Route.put('put', () => 'put');
      final response = await put('/put');
      expect(response.statusCode, 200);
      expect(response.body, 'put');
    });

    test('Route.patch()', () async {
      Route.patch('patch', () => 'patch');
      final response = await patch('/patch');
      expect(response.statusCode, 200);
      expect(response.body, 'patch');
    });

    test('Route.delete()', () async {
      Route.delete('delete', () => 'delete');
      final response = await delete('/delete');
      expect(response.statusCode, 200);
      expect(response.body, 'delete');
    });

    test('Route.via([PUT, PATCH])', () async {
      Route.via(['PUT', 'PATCH'], 'update', () => 'update');
      final response = await put('/update');
      expect(response.statusCode, 200);
      expect(response.body, 'update');
      final response2 = await patch('/update');
      expect(response2.statusCode, 200);
      expect(response2.body, 'update');
    });

    test('Route.group(...)', () async {
      Route.group(RouteOptions(prefix: 'group'), () {
        Route.get('get', () => 'get group');
      });

      final response = await get('/group/get');
      expect(response.statusCode, 200);
      expect(response.body, 'get group');
    });
  });

  group('Route instance methods', () {
    test('get', () async {
      Route.prefix('prefix').get('get', () => 'get');
      expect((await get('/prefix/get')).body, 'get');
    });
    test('post', () async {
      Route.prefix('prefix').post('post', () => 'post');
      final response = await post('/prefix/post');
      expect(response.statusCode, 200);
      expect(response.body, 'post');
    });
    test('put', () async {
      Route.prefix('prefix').put('put', () => 'put');
      final response = await put('/prefix/put');
      expect(response.statusCode, 200);
      expect(response.body, 'put');
    });
    test('patch', () async {
      Route.prefix('prefix').patch('patch', () => 'patch');
      final response = await patch('/prefix/patch');
      expect(response.statusCode, 200);
      expect(response.body, 'patch');
    });
    test('delete', () async {
      Route.prefix('prefix').delete('delete', () => 'delete');
      final response = await delete('/prefix/delete');
      expect(response.statusCode, 200);
      expect(response.body, 'delete');
    });
  });

  group('Route exceptions', () {
    test('throws exception if handler is not a function or Type', () async {
      Route.get('wront-type-handler', 'not a function');
      final response = await get('/wront-type-handler');
      expect(response.statusCode, 500);
      expect(response.body, contains('This type of handler is not supported.'));
    });

    test('throws an error if controller doesnt have specified method in route',
        () async {
      Route.get('/undefined-method', SomeController, 'test');
      final response = await get('/undefined-method');
      expect(response.statusCode, 500);
      expect(
          response.body,
          contains(
              "Method [test] not found in controller [Instance of 'SomeController']"));
    });

    test(
        'throws an exception if invoking route(param) function without params when the route has params',
        () {
      Route.post('/some-post-test/{id}', (int id) => 'test')
          .name('some-post-test');
      expect(() => route('some-post-test'),
          toThrow(ArgumentError, 'Missing route params [{id}]'));
    });

    test(
        'throws an exception if try to pass an invalid route param type such as boolean',
        () {
      Route.post('/some-post-test/{valid}', (bool valid) => 'test')
          .name('some-post-test');
      expect(() => route('some-post-test', true),
          toThrow(ArgumentError, 'Invalid param type [true]'));
    });

    test('throws an exception if middleware is invalid', () async {
      expect(
        () => Route.middlewares(123).get('/never-get', () => 'will never work'),
        toThrow(ArgumentError, 'Invalid type for middleware [123]'),
      );
    });

    group('response types', () {
      test('accepts string', () async {
        Route.get('/some-string', () => 'some string');
        final response = await get('/some-string');
        expect(response.statusCode, 200);
        expect(response.body, 'some string');
      });

      test('converts everything to string', () async {
        Route.get('/return-object', () => Route);
        final response = await get('/return-object');
        expect(response.statusCode, 200);
        expect(response.body, "Route");
      });

      test('returns empty string for null values', () async {
        Route.get('/return-null', () => null);
        final response = await get('/return-null');
        expect(response.statusCode, 200);
        expect(response.body, '');
      });

      test('returns a map to json', () async {
        Route.get('return-map', () => {'key': 'value'});
        final response = await get('return-map');
        expect(response.statusCode, 200);
        expect(response.body, '{"key":"value"}');
      });
    });
  });
}

class SomeController extends Controller {}
