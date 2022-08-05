import 'dart:async';
import 'dart:convert';

import 'package:tunder/tunder.dart';
import 'package:tunder/http.dart';
import 'package:tunder/src/core/pipeline.dart';
import 'package:tunder/src/exceptions/route_not_found_exception.dart';
import 'package:tunder/src/http/route_entry.dart';
import 'package:tunder/src/http/route_definitions.dart';
import 'package:tunder/src/http/route_options.dart';

class Router implements RouteDefinitions {
  Application app;
  List middlewares = [];
  Map<String, Type> aliasMiddleware = {};
  final List<RouteEntry> routes = [];
  final List<RouteOptions> _groupStack = [];

  Router(this.app);

  RouteEntry prefix(String prefix) =>
      _newRoute([RouteEntry.GET, RouteEntry.HEAD], prefix, () => null)
          .setOption(prefix: prefix);

  void discovery(Type controller) =>
      _newRoute([RouteEntry.GET], '', () => null).discovery(controller);

  RouteEntry middleware(middlewares) =>
      _newRoute([RouteEntry.GET, RouteEntry.HEAD], '', () => null)
          .setOption(middleware: middlewares);

  RouteEntry via(List<String> methods, String uri, handler, [String? action]) =>
      _addRoute(methods, uri, handler, action);

  RouteEntry get(String uri, handler, [String? action]) =>
      _addRoute([RouteEntry.GET, RouteEntry.HEAD], uri, handler, action);

  RouteEntry post(String uri, handler, [String? action]) =>
      _addRoute([RouteEntry.POST], uri, handler, action);

  RouteEntry put(String uri, handler, [String? action]) =>
      _addRoute([RouteEntry.PUT], uri, handler, action);

  RouteEntry delete(String uri, handler, [String? action]) =>
      _addRoute([RouteEntry.DELETE], uri, handler, action);

  RouteEntry patch(String uri, handler, [String? action]) =>
      _addRoute([RouteEntry.PATCH], uri, handler, action);

  RouteEntry _addRoute(List<String> methods, String path, handler,
          [String? action]) =>
      _newRoute(methods, path, handler, action)..register();

  RouteEntry _newRoute(List<String> methods, path, handler, [String? action]) =>
      RouteEntry(
        methods: methods,
        path: path,
        handler: handler,
        action: action,
        container: app,
        router: this,
      );

  void group(RouteOptions options, Function registrar) {
    // add the group attributes to stack
    _groupStack.add(options);
    // load routes
    registrar();
    // remove latest group attributes from stack
    _groupStack.removeLast();
  }

  register(RouteEntry route) {
    if (_groupStack.isNotEmpty) route.mergeOptions(_groupStack.last);

    routes.add(route);
  }

  FutureOr runRoute(Request request, RouteEntry route) => Pipeline(app)
          .send(request)
          .through(_gatherMiddlewares(route))
          .then((request) async {
        return toResponse(request, await route.run(request));
      });

  Response toResponse(Request request, dynamicResponse) {
    Response response = Response.from(request);
    if (dynamicResponse is String) return response..body = dynamicResponse;
    if (dynamicResponse is Map)
      return response..body = jsonEncode(dynamicResponse);

    return response..body = dynamicResponse?.toString() ?? '';
  }

  flush() {
    routes.clear();
    middlewares = [];
    aliasMiddleware = {};
  }

  RouteEntry findRouteByName(String name) {
    RouteEntry? route = routes.firstWhereOrNull((route) => route.nameIs(name));

    if (route == null)
      throw RouteNotFoundException("Route [$name] not defined.");

    return route;
  }

  List _gatherMiddlewares(RouteEntry route) {
    var currentMiddlewares = [...middlewares, ...route.middlewares];

    return _resolveMiddlewares(currentMiddlewares.toSet().toList());
  }

  List _resolveMiddlewares(List middlewares) =>
      middlewares.map((m) => m is String ? aliasMiddleware[m] : m).toList();
}
