import 'package:dotenv/dotenv.dart';
import 'package:tunder/extensions.dart';
import 'package:tunder/http.dart';
import 'package:tunder/src/http/route_entry.dart';

import '../core/application.dart';

dynamic app([key]) {
  var _app = Application();
  return key != null ? _app.getSafe(key) : _app;
}

String? env(String key) {
  var environment = app('env');

  if (environment != null) return environment[key];

  var dotenv = DotEnv()..load();
  app().singleton('env', dotenv);

  return dotenv[key];
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
