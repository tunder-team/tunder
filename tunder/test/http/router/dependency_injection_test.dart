import 'package:test/test.dart';
import 'package:tunder/http.dart';
import 'package:tunder/utils.dart';

import '../../feature.dart';
import '../../helpers.dart';

main() {
  feature();

  setUp(() {
    app(Router).flush();
  });

  group('Dependency Injection in Controllers', () {
    test('it injects simple classes', () async {
      Route.get('/users', UserController, 'index');

      var response = await get('/users');
      expect(response.statusCode, 200);
      expect(response.body, 'doSomething worked');
    });
  });
}

class UserController extends Controller {
  index(Request request, SomeService service) => service.doSomething();
}

class SomeService {
  doSomething() => 'doSomething worked';
}
