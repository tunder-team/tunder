import 'package:tunder/http.dart';
import 'package:tunder/src/exceptions/route_not_found_exception.dart';
import 'package:tunder/utils.dart';
import 'package:test/test.dart';

import '../../feature.dart';
import '../../helpers.dart' as http;

main() {
  feature();

  group('Discovery function:', () {
    setUp(() {
      Route.prefix('discovery')
          .name('discovery.')
          .discovery(TunderUserController);

      Route.discovery(PartialController);
    });

    var generatedRoutesForTunderUserController = {
      'index': {'expected': '/discovery/tunder-user'},
      'show': {'expected': '/discovery/tunder-user/123', 'param': 123},
      'create': {'expected': '/discovery/tunder-user/create'},
      'store': {'expected': '/discovery/tunder-user'},
      'update': {'expected': '/discovery/tunder-user/123', 'param': 123},
      'delete': {'expected': '/discovery/tunder-user/123', 'param': 123},
      'force-delete': {
        'expected': '/discovery/tunder-user/123/force',
        'param': 123
      },
    };

    generatedRoutesForTunderUserController.keys.toList().forEach((method) {
      var expectedUrl =
          generatedRoutesForTunderUserController[method]!['expected'];
      var param = generatedRoutesForTunderUserController[method]!['param'];
      var routeName = 'discovery.tunder-user';

      test('action "$method" route: [$routeName.$method] -> $expectedUrl', () {
        expect(route('discovery.tunder-user.$method', param), expectedUrl);
      });
    });

    test(
      'Route.discovery(PartialController) generates only route [partial.index]',
      () => expect(route('partial.index'), '/partial'),
    );

    group('TunderUserController real requests for resourceful action:', () {
      var name = 'discovery.tunder-user';

      test('index', () async {
        var response = await http.get(route('$name.index'));
        expect(response.statusCode, 200);
        expect(response.body, 'index worked');
        var wrong = await http.put(route('$name.index'));
        expect(wrong.statusCode, Response.HTTP_NOT_FOUND);
      });
      test('show', () async {
        var response = await http.get(route('$name.show', 123));
        expect(response.statusCode, 200);
        expect(response.body, 'show worked 123');
        var wrong = await http.post(route('$name.show', 123));
        expect(wrong.statusCode, Response.HTTP_NOT_FOUND);
      });
      test('create', () async {
        var response = await http.get(route('$name.create'));
        expect(response.statusCode, 200);
        expect(response.body, 'create worked');
        var wrong = await http.post(route('$name.create'));
        expect(wrong.statusCode, Response.HTTP_NOT_FOUND);
      });
      test('store', () async {
        var response = await http.post(route('$name.store'));
        expect(response.statusCode, 200);
        expect(response.body, 'store worked');
        var wrong = await http.put(route('$name.store'));
        expect(wrong.statusCode, Response.HTTP_NOT_FOUND);
      });
      test('update', () async {
        var response = await http.put(route('$name.update', 123));
        expect(response.statusCode, 200);
        expect(response.body, 'update worked 123');
        var wrong = await http.post(route('$name.update', 123));
        expect(wrong.statusCode, Response.HTTP_NOT_FOUND);
      });
      test('delete', () async {
        var response = await http.delete(route('$name.delete', 123));
        expect(response.statusCode, 200);
        expect(response.body, 'delete worked 123');
        var wrong = await http.post(route('$name.delete', 123));
        expect(wrong.statusCode, Response.HTTP_NOT_FOUND);
      });
      test('force-delete', () async {
        var response = await http.delete(route('$name.force-delete', 123));
        expect(response.statusCode, 200);
        expect(response.body, 'forceDelete worked 123');
        var wrong = await http.post(route('$name.force-delete', 123));
        expect(wrong.statusCode, Response.HTTP_NOT_FOUND);
      });
    });

    group('TunderUserController dynamic routes for non-resourceful actions',
        () {
      test(
          'getAction generates [discovery.tunder-user.get-action], GET /discovery/tunder-user/get-action',
          () async {
        var path = route('discovery.tunder-user.get-action');
        expect(path, '/discovery/tunder-user/get-action');
        var response = await http.get(path);
        expect(response.statusCode, 200);
        expect(response.body, 'getAction worked');
      });
      test(
          'postAction generates [discovery.tunder-user.post-action], POST /discovery/tunder-user/post-action',
          () async {
        var path = route('discovery.tunder-user.post-action');
        expect(path, '/discovery/tunder-user/post-action');
        var response = await http.post(path);
        expect(response.statusCode, 200);
        expect(response.body, 'postAction worked');
      });
      test(
          'putAction generates [discovery.tunder-user.put-action], PUT /discovery/tunder-user/put-action/123/yes',
          () async {
        var path = route('discovery.tunder-user.put-action', [123, 'yes']);
        expect(path, '/discovery/tunder-user/put-action/123/yes');
        var response = await http.put(path);
        expect(response.statusCode, 200);
        expect(response.body, 'putAction worked 123 yes');
      });
      test(
          'patchAction generates [discovery.tunder-user.patch-action], PATCH /discovery/tunder-user/patch-action/123',
          () async {
        var path = route('discovery.tunder-user.patch-action', 123);
        expect(path, '/discovery/tunder-user/patch-action/123');
        var response = await http.patch(path);
        expect(response.statusCode, 200);
        expect(response.body, 'patchAction worked 123');
      });
      test(
          'deleteAction generates [discovery.tunder-user.delete-action], DELETE /discovery/tunder-user/delete-action/123',
          () async {
        var path = route('discovery.tunder-user.delete-action', 123);
        expect(path, '/discovery/tunder-user/delete-action/123');
        var response = await http.delete(path);
        expect(response.statusCode, 200);
        expect(response.body, 'deleteAction worked 123');
      });
      test("shouldn't generate route for private methods", () async {
        expect(() => route('discovery.tunder-user._some-private-method'),
            throwsA(TypeMatcher<RouteNotFoundException>()));
        expect(() => route('discovery.tunder-user.some-private-method'),
            throwsA(TypeMatcher<RouteNotFoundException>()));
      });
    });
  });
}

class TunderUserController extends Controller {
  index() {
    return 'index worked';
  }

  show(int id) {
    return 'show worked $id';
  }

  create() {
    return 'create worked';
  }

  store() {
    return 'store worked';
  }

  update(int id) {
    return 'update worked $id';
  }

  delete(int id) {
    return 'delete worked $id';
  }

  forceDelete(int id) {
    return 'forceDelete worked $id';
  }

  getAction() {
    return 'getAction worked';
  }

  @Route(method: 'post')
  postAction() {
    return 'postAction worked';
  }

  @Route(method: 'put')
  putAction(Request request, int id, String name) {
    return 'putAction worked $id $name';
  }

  @Route(method: 'patch')
  patchAction(int id) {
    return 'patchAction worked $id';
  }

  @Route(method: 'delete')
  deleteAction(int id) {
    return 'deleteAction worked $id';
  }

  // ignore: unused_element
  _somePrivateMethod() {
    return 'should not generate route';
  }
}

class PartialController extends Controller {
  index() {
    return 'index worked';
  }
}
