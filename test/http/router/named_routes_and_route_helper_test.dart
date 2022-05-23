import 'package:tunder/http.dart';
import 'package:tunder/src/exceptions/route_not_found_exception.dart';
import 'package:tunder/utils.dart';
import 'package:test/test.dart';

import '../../feature.dart';

main() {
  feature();

  setUp(() {
    app(Router).flush();
  });

  group('Named routes and "route" helper', () {
    test('find route by name', () {
      // Arrange
      Route.get('jetete/worked', () => 'jetete worked').name('my.jetete');
      // Assert
      expect(route('my.jetete'), '/jetete/worked');
    });

    test("throws a meaninful error when route doesn't exist", () {
      expect(
        () => route('strange.name'),
        toThrow(RouteNotFoundException, 'Route [strange.name] not defined'),
      );
    });

    test('accepts a primitive value as route param as the second argument', () {
      // Arrange
      Route.get('users/{user}/show', () => 'users worked').name('users.show');
      // Assert
      expect(route('users.show', 2), '/users/2/show');
    });

    test('accepts a list of params as second argument', () {
      // Arrange
      Route.get('users/{user}/show/{post}', () => 'users worked')
          .name('users.show.post');
      // Assert
      expect(route('users.show.post', [2, 3]), '/users/2/show/3');
    });

    test(
        'when list of params exceeds the length of route params, just ignores it',
        () {
      // Arrange
      Route.get('users/{user}/show', () => 'users worked').name('users.show');
      // Assert
      expect(route('users.show', [2, 3]), '/users/2/show');
    });

    test('accepts a map of params as second argument', () {
      // Arrange
      Route.get('users/{user}/show/{post}', () => 'users worked')
          .name('users.show.post');
      // Assert
      expect(
          route('users.show.post', {'post': 3, 'user': 2}), '/users/2/show/3');
    });

    test('when map of params contains extra keys it is passed as query params',
        () {
      // Arrange
      Route.get('users/{user}/show/{post}', () => 'users worked')
          .name('users.show.post');
      // Assert
      expect(route('users.show.post', {'user': 2, 'post': 3, 'extra': 'field'}),
          '/users/2/show/3?extra=field');
    });

    test('when map of params misses keys it throws an exception', () {
      // Arrange
      Route.get('users/{user}/show/{post}', () => 'users worked')
          .name('users.show.post');
      // Assert
      expect(
          () => route('users.show.post', {'user': 2}),
          throwsA(predicate((e) =>
              e is ArgumentError &&
              e.message == "Missing route param 'post'")));
    });
  });
}
