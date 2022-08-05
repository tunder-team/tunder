import 'package:tunder/src/http/route_entry.dart';
import 'package:tunder/src/http/route_options.dart';
import 'package:tunder/src/http/router.dart';
import 'package:tunder/utils.dart';

class Route {
  final String? method;
  final List<String>? methods;
  final dynamic middleware;

  const Route({this.method, this.methods, this.middleware});

  static Router get router => app(Router);

  static RouteEntry get(String path, handler, [String? action]) =>
      router.get(path, handler, action);

  static RouteEntry post(String path, handler, [String? action]) =>
      router.post(path, handler, action);

  static RouteEntry put(String path, handler, [String? action]) =>
      router.put(path, handler, action);

  static RouteEntry delete(String path, handler, [String? action]) =>
      router.delete(path, handler, action);

  static RouteEntry patch(String path, handler, [String? action]) =>
      router.patch(path, handler, action);

  static void group(RouteOptions options, Function registrar) =>
      router.group(options, registrar);

  static RouteEntry prefix(String prefix) => router.prefix(prefix);

  static void discovery(Type controller) => router.discovery(controller);

  static RouteEntry middlewares(middlewares) => router.middleware(middlewares);

  static RouteEntry via(
    List<String> methods,
    String uri,
    handler, [
    String? action,
  ]) =>
      router.via(methods, uri, handler, action);
}
