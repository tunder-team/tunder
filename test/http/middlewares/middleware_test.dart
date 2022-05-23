import 'package:tunder/http.dart';
import 'package:tunder/utils.dart';
import 'package:test/test.dart';

import '../../feature.dart';
import '../../helpers.dart' as http;

main() {
  feature();

  setUp(() {
    app(Router).flush();
  });

  group('Middlewares', () {
    test('can be defined in the route', () async {
      Route.get('/something', () => 'it worked').middleware(AlwaysNotFound);

      var response = await http.get('/something');

      expect(response.statusCode, 404);
    });
    test('can be defined in the kernel', () async {
      // Arrange
      Kernel kernel = app(Kernel);
      kernel.middlewares.addAll([AlwaysNotFound]);
      kernel.syncMiddlewaresToRouter();

      // Act
      Route.get('/something', () => 'it worked');

      var response = await http.get('/something');

      // Assert
      expect(response.statusCode, Response.HTTP_NOT_FOUND);
      kernel.middlewares.remove(AlwaysNotFound);
    });
    test('can change response', () async {
      // Arrange
      Kernel kernel = app(Kernel);
      kernel.middlewares.addAll([
        (request, next) async {
          var response = await next(request) as Response;
          response.headers.update(
            'my-header',
            (value) => '$value with success',
            ifAbsent: () => 'with success',
          );

          return response;
        },
        (request, next) async {
          Response response = await next(request);

          response.headers.update(
            'my-header',
            (_) => 'worked',
            ifAbsent: () => 'worked',
          );

          return response;
        }
      ]);
      kernel.syncMiddlewaresToRouter();

      Route.get('/something', () => 'it worked');

      // Act
      var response = await http.get('/something');

      // Assert
      expect(response.body, 'it worked');
      expect(response.statusCode, 200);
      expect(response.headers['my-header'], 'worked with success');
    });
  });
}

class AlwaysNotFound implements Middleware {
  handle(request, next) {
    return Response.notFound();
  }
}
