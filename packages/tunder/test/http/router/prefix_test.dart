import 'package:tunder/http.dart';
import 'package:test/test.dart';

import '../../feature.dart';
import '../../helpers.dart' as http;

main() {
  feature();

  group('Prefix function:', () {
    setUp(() {
      Route.prefix('prefix').get('controller', TestController, 'index');
    });

    test('it works with controller', () async {
      var response = await http.get('prefix/controller');
      expect(response.statusCode, 200);
      expect(response.body, 'index worked');
    });
  });
}

class TestController extends Controller {
  index() {
    return 'index worked';
  }
}
