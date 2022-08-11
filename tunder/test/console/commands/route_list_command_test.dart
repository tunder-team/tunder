import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tunder/http.dart';
import 'package:tunder/src/console/commands/route_list_command.dart';
import 'package:tunder/utils.dart';
import 'package:colorx/colorx.dart';

import 'wipe_command_test.dart';

main() {
  group('RouteListCommand', () {
    setUp(() => (app(Router) as Router).flush());

    test('responds to the routes command', () {
      expect(RouteListCommand().name, equals('routes'));
    });

    test('has a description', () {
      expect(RouteListCommand().description, equals('Lists all routes'));
    });

    test('list all registered routes', () async {
      // Arrange
      Route.get('/', () => 'home').name('home');
      Route.get('users', () => 'home').name('users');

      final test = skyCommandContext();

      // Act
      final exitCode = await test.sky.run(['routes']);

      // Assert
      expect(exitCode, equals(0));
      verify(() => test.logger.info(captureAny(that: contains('/')))).called(1);
      verify(() => test.logger.info(captureAny(that: contains('users'))))
          .called(1);
    });

    test('it displays the name of the route in gray', () async {
      Route.get('/jetete', () => 'whatever').name('weird');
      final test = skyCommandContext();

      await test.sky.run(['routes']);

      verify(() => test.logger.info(captureAny(that: contains('weird'.gray))))
          .called(1);
    });

    test('it displays route params in blue color', () async {
      Route.get('/users/{user}', () => 'whatever').name('users');
      final test = skyCommandContext();

      await test.sky.run(['routes']);

      verify(() => test.logger.info(captureAny(that: contains('{user}'.blue))))
          .called(1);
    });

    test('it displays the GET methods in blue and HEAD in gray', () async {
      Route.get('some', () => 'whatever').name('some');
      final test = skyCommandContext();

      await test.sky.run(['routes']);

      verify(
        () => test.logger.info(
          captureAny(
            that: allOf(
              contains('GET'.blue),
              contains('HEAD'.gray),
            ),
          ),
        ),
      );
    });

    test('it displays POST and PUT methods in yellow', () async {
      Route.post('post', () => 'whatever').name('post');
      Route.put('put', () => 'whatever').name('put');
      final test = skyCommandContext();

      await test.sky.run(['routes']);
      verify(() => test.logger.info(captureAny(that: contains('POST'.yellow))))
          .called(1);
      verify(() => test.logger.info(captureAny(that: contains('PUT'.yellow))))
          .called(1);
    });

    test('it displays DELETE methods in red', () async {
      Route.delete('delete', () => 'whatever').name('delete');
      final test = skyCommandContext();

      await test.sky.run(['routes']);
      verify(() => test.logger.info(captureAny(that: contains('DELETE'.red))))
          .called(1);
    });

    test('displays the name of the controller with method', () async {
      Route.discovery(TestController);
      final test = skyCommandContext();

      await test.sky.run(['routes']);

      verify(
        () => test.logger.info(
          captureAny(
            that: allOf(
              contains('#'.gray.dim),
              contains('TestController'.gray.underline),
              contains('index'.gray.dim),
            ),
          ),
        ),
      ).called(1);
    });

    test('displays the routes with annotations', () async {});
  });
}

SkyCommandContext skyCommandContext() => SkyCommandContext(RouteListCommand());

class TestController extends Controller {
  index() => 'index';
}
