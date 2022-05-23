import 'dart:mirrors';

import 'package:tunder/extensions.dart';
import 'package:tunder/http.dart';
import 'package:tunder/src/http/route_entry.dart';

import '../core/application.dart';

dynamic app([key]) {
  var _app = Application();
  return key != null ? _app.get(key) : _app;
}

String str(subject) => subject.toString();

String url(String path) {
  if (path.startsWith('http')) return path;

  String appUrl = app().get('app.url');

  return "${str(appUrl).trimWith('/')}/${str(path).trimWith('/')}";
}

String route(name, [dynamic params]) {
  Router router = app(Router);
  RouteEntry route = router.findRouteByName(name);

  return route.pathWith(params);
}

bool hasMethod(dynamic obj, String methodName) {
  var mirror = reflect(obj);

  return mirror.type.declarations.entries
      .where((declaration) => declaration.value is MethodMirror)
      .contains((MethodMirror method) {
    return method.simpleName == Symbol(methodName);
  });
}
