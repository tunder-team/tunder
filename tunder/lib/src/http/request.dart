import 'dart:io';

import 'package:tunder/http.dart';
import 'package:tunder/src/core/container.dart';
import 'package:tunder/src/http/route_entry.dart';

class Request {
  HttpRequest original;
  HttpResponse response;
  String method;
  Map<String, String?> headers;
  Uri get uri => original.uri;
  late RouteEntry route;
  late Container container;

  Router get router => container.get(Router);

  Request({
    required this.method,
    required this.original,
    required this.response,
    this.headers = const {},
  });
  Request.fromBase(HttpRequest httpRequest)
      : this(
          method: httpRequest.method,
          original: httpRequest,
          response: httpRequest.response,
          headers: {'content-type': httpRequest.headers.contentType?.value},
        );

  RouteEntry? findRoute() {
    var route = router.routes.firstWhereOrNull(
      (route) => route.matches(this),
    );

    if (route == null) return null;

    return route;
  }

  void setRoute(RouteEntry route) => this.route = route;

  dynamic get(String name) {
    dynamic value = uri.queryParameters[name] ?? null;
    if (value == null) return value;
    if (value.contains(','))
      return value.split(',').map(_tryParsePrimitives).toList();

    return _tryParsePrimitives(value);
  }

  getRouteParam(dynamic name, {Type type = String}) {
    if (name is String) name = Symbol(name);
    if (name is! Symbol) throw ArgumentError.value(name, 'name');

    return route.paramValue(
      name,
      request: this,
      castTo: type,
    );
  }

  _tryParsePrimitives(String value) {
    if (value == '') return null;
    if (int.tryParse(value) != null) return int.tryParse(value);
    if (double.tryParse(value) != null) return double.tryParse(value);
    if (value == 'null') return null;
    if (value == 'undefined') return null;
    if (value == 'true') return true;
    if (value == 'false') return false;

    return value;
  }
}
