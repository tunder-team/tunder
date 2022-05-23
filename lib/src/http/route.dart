import 'package:tunder/src/http/route_entry.dart';
import 'package:tunder/src/http/route_options.dart';
import 'package:tunder/src/http/router.dart';
import 'package:tunder/utils.dart';

class Route {
  const Route({this.method, this.methods, this.middleware});

  final String? method;
  final List<String>? methods;
  final dynamic middleware;
  static Router? _router;

  static Router get router {
    _router = _router ?? app(Router);

    return _router!;
  }

  static RouteEntry delete(String path, handler, [String? action]) {
    return router.delete(path, handler, action);
  }

  static RouteEntry get(String path, handler, [String? action]) {
    return router.get(path, handler, action);
  }

  static RouteEntry patch(String path, handler, [String? action]) {
    return router.patch(path, handler, action);
  }

  static RouteEntry post(String path, handler, [String? action]) {
    return router.post(path, handler, action);
  }

  static RouteEntry put(String path, handler, [String? action]) {
    return router.put(path, handler, action);
  }

  static void group(RouteOptions options, Function registrar) {
    return router.group(options, registrar);
  }

  static RouteEntry prefix(String prefix) {
    return router.prefix(prefix);
  }

  static void discovery(Type controller) {
    return router.discovery(controller);
  }

  static RouteEntry middlewares(middlewares) {
    return router.middleware(middlewares);
  }

  static RouteEntry via(List<String> methods, String uri, handler,
      [String? action]) {
    return router.via(methods, uri, handler, action);
  }
}
