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

  group('Routing', () {
    test("GET to '/path' with closure", () async {
      Route.get('/path', () => 'path is working.');

      var response = await http.get('/path');
      expect(response.body, 'path is working.');
    });

    test("GET to '/path' and resolve closure dependencies", () async {
      // Arrange
      Route.get('/path', (Request request, Router router) {
        return 'ioc working';
      });
      // Act
      var response = await http.get('/path');
      // Assert
      expect(response.body, 'ioc working');
    });

    test("GET to '/path' with controller", () async {
      // Arrange
      Route.get('/path', TestController, 'index');
      // Act
      var response = await http.get('/path');
      // Assert
      expect(response.body, 'TestController worked');
      expect(response.statusCode, 200);
    });
    ;
    test("PUT to '/path' matches method type", () async {
      // Arrange
      Route.put('/path', TestController, 'index');
      // Act
      var response = await http.put('/path');
      // Assert
      expect(response.body, 'TestController worked');
      expect(response.statusCode, 200);
    });
    test("Returns 405 if method type doesn't match", () async {
      // Arrange
      Route.put('/path', TestController, 'index');
      // Act
      var response = await http.delete('/path');
      // Assert
      expect(response.statusCode, Response.HTTP_NOT_FOUND);
    });
    test("Matches '/users/2' to route param '/users/{user}' with closure",
        () async {
      // Arrange
      Route.put('/users/{user}', (int user) {
        return 'User id is $user.';
      });
      // Act
      var response = await http.put('/users/2');
      // Assert
      expect(response.body, 'User id is 2.');
      expect(response.statusCode, 200);
    });
    test("Matches '/users/2' to route param '/users/{user}' with controller",
        () async {
      // Arrange
      Route.put('/users/{user}', UserController, 'show');
      // Act
      var response = await http.put('/users/3');
      // Assert
      expect(response.body, 'User id is 3.');
      expect(response.statusCode, 200);
    });

    test(
        "Matches '/users/2' to route param '/users/{user}' and casts to double",
        () async {
      // Arrange
      Route.put('/users/{user}', (double user) {
        return 'User id is $user';
      });
      // Act
      var response = await http.put('/users/3.45');
      // Assert
      expect(response.body, 'User id is 3.45');
      expect(response.statusCode, 200);
    });

    test(
        "Matches '/users/2' to route param '/users/{user}' and casts to string by default",
        () async {
      // Arrange
      Route.put('/users/{user}', (user) {
        return 'User id is $user';
      });
      // Act
      var response = await http.put('/users/3.45');
      // Assert
      expect(response.body, 'User id is 3.45');
      expect(response.statusCode, 200);
    });

    test("Matches same number of parameters", () async {
      Route.put('/users/{user}', () => 'should avoid this result');
      Route.put('/users/{user}/posts', (int user) {
        return 'User id is $user';
      });
      var response = await http.put('/users/32/posts');
      expect(response.body, 'User id is 32');
      expect(response.statusCode, 200);
    });
  });
}

class TestController extends Controller {
  index() => 'TestController worked';

  methodWithDependencies(Request request, Router router) =>
      'TestController worked with dependencies';
}

class UserController extends Controller {
  show(Request request, int user) => 'User id is $user.';

  index(Request request, SomeService service) => service.doSomething();
}

class SomeService {
  doSomething() => 'doSomething worked';
}
