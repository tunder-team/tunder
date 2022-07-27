import 'package:tunder/extensions.dart';
import 'package:tunder/src/core/pipeline.dart';
import 'package:tunder/utils.dart';
import 'package:test/test.dart';

main() {
  group('Pipeline class', () {
    test('accepts a list of classes with handle methods', () async {
      var passable = {'name': ''};
      var returned = await Pipeline(app()).send(passable).through([
        AddMarco,
        AddSantos,
      ]).thenReturn();

      expect(returned, equals(passable));
      expect(true, identical(returned, passable));
      expect(passable['name'], equals('Marco Santos'));
    });

    test('accepts async handle methods', () async {
      var request = {'name': ''};
      var response = await Pipeline(app()).send(request).through([
        AddMarco,
        AsyncMiddleware,
        AddSantos,
      ]).thenReturn();

      expect(response, equals(request));
      expect(response['name'], equals('Marco <middle pause> Santos'));
    });

    test('accepts primitives as passable and functions as handlers', () async {
      var passable = 'a string';
      var response = await Pipeline(app()).send(passable).through([
        (passable, next) => 1.second.delay.then((_) => next('Final result'))
      ]).thenReturn();

      expect(response, TypeMatcher<String>());
      expect(response, 'Final result');
    });
  });
}

class AddMarco {
  handle(passable, next) {
    passable['name'] += 'Marco';
    return next(passable);
  }
}

class AddSantos {
  handle(passable, next) {
    passable['name'] += ' Santos';
    return next(passable);
  }
}

class AsyncMiddleware {
  handle(passable, next) async {
    await 1.second.delay;
    passable['name'] += ' <middle pause>';
    return next(passable);
  }
}
