import 'package:test/test.dart';
import 'package:tunder/http.dart';
import 'package:tunder/src/http/route_options.dart';

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
}
