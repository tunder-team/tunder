import 'dart:math';

import 'package:colorx/colorx.dart';
import 'package:tunder/console.dart';
import 'package:tunder/http.dart';

class RouteListCommand extends Command<int> {
  final name = 'routes';
  final description = 'Lists all routes';

  Future<int> run() async {
    Router router = sky.app.get(Router);
    final longestPath =
        router.routes.map((route) => route.path.length).reduce(max) + 1;

    info('');
    router.routes
        .map((route) =>
            _RoutePrinter.fromMap(route.toMap())..longestPath = longestPath)
        .forEach((route) {
      info('$route');
    });
    info('');

    return 0;
  }
}

class _RoutePrinter {
  String? name;
  late String path;
  late List<String> methods;
  late List middlewares;
  late int longestPath;
  late String handler;

  int get _methodsLength => this.methods.join('|').length;

  _RoutePrinter.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    path = map['path'];
    methods = map['methods'];
    handler = map['handler'];
  }

  String toString() {
    final methods = _parseMethods();
    final name = _parseName();

    return '${methods} '
            '${_margin(min: 10, length: _methodsLength)} '
            '${_parsePath(path)} '
            '${_margin(min: longestPath + 5, length: path.length, using: '.')} '
            '${name != '' ? '$name ' : ''}'
            '${'»'.gray.dim} ${_parseHandler(handler)}'
        .trim();
  }

  String _margin({required int length, required int min, String using = ' '}) {
    final diff = min - length;

    return ''.padLeft(diff > 0 ? diff : 0, using).gray.dim;
  }

  String _parseHandler(String handler) {
    if (handler == 'function') return handler.gray.dim;

    final parts = handler.split('@');
    final controller = '#'.gray.dim + '${parts.first}'.gray.underline;
    final method = parts.last;

    return '${controller} ${'@'.gray.dim} ${method.gray.dim}';
  }

  String _parseName() {
    if (name == null) return '';

    return '$name'.gray;
  }

  String _parsePath(String path) => path
      .split('/')
      .map((part) => part.startsWith('{') ? part.blue : part)
      .join('/');

  String _parseMethods() => this.methods.map(_parseMethod).join('|'.gray);

  String _parseMethod(String method) {
    if (method == 'GET') return method.blue;
    if (method == 'POST') return method.yellow;
    if (method == 'PUT') return method.yellow;
    if (method == 'PATCH') return method.yellow;
    if (method == 'DELETE') return method.red;

    return method.gray;
  }
}
