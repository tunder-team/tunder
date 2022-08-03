import 'dart:mirrors';

import 'package:tunder/http.dart';
import 'package:tunder/utils.dart';
import 'package:test/test.dart';

import '../../feature.dart';
import '../../helpers.dart' as http;

main() {
  feature();

  group('Http verbs:', () {
    late InstanceMirror router;
    var verbs = {
      'get': http.get,
      'put': http.put,
      'post': http.post,
      'patch': http.patch,
      'delete': http.delete
    };

    setUp(() {
      app(Router).flush();
      router = reflect(app(Router));
    });

    verbs.entries.forEach((httpVerb) {
      test('it works with ${httpVerb.key}', () async {
        router.invoke(
          Symbol(httpVerb.key),
          ['controller', TestController, 'index'],
        );
        var response = await httpVerb.value('controller');
        expect(response.statusCode, 200);
        expect(response.body, 'index worked');
      });
    });
  });
}

class TestController extends Controller {
  index() => 'index worked';
}
