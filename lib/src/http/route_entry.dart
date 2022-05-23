import 'dart:mirrors';

import 'package:tunder/extensions.dart';
import 'package:tunder/http.dart';
import 'package:tunder/src/core/container.dart';
import 'package:tunder/src/http/route_definitions.dart';
import 'package:tunder/src/http/route_options.dart';
import 'package:tunder/utils.dart';
import 'package:tunder/tunder.dart';
import 'package:slugify/slugify.dart';
import 'package:recase/recase.dart';

class RouteEntry implements RouteDefinitions {
  late String path;
  late List<String> methods;
  late dynamic handler;
  late Container container;
  late Router router;
  RouteOptions? options;

  String? _name;
  String? action;
  List middlewares = [];

  static const GET = 'GET';
  static const HEAD = 'HEAD';
  static const PUT = 'PUT';
  static const PATCH = 'PATCH';
  static const POST = 'POST';
  static const DELETE = 'DELETE';

  Uri get uri => Uri.parse(url(path));

  RouteEntry({
    required this.methods,
    required this.path,
    required this.handler,
    required this.container,
    required this.router,
    this.action,
    this.options,
  });

  List<String> get parameters {
    return uri.pathSegments.where(_isParameter).toList();
  }

  RouteEntry name(String name) {
    _name = _name != null ? '$_name$name' : name;
    setOption(name: _name);

    return this;
  }

  RouteEntry prefix(String prefix) {
    return setOption(prefix: prefix);
  }

  void group(routes) {
    router.group(options ?? RouteOptions(), routes);
  }

  RouteEntry middleware(middleware) {
    setOption(middleware: middleware);
    // if (middleware is Type) middlewares.add(middleware);
    // if (middleware is List) middlewares.addAll(middleware);

    // if (middlewares.isNotEmpty) setOption(middleware: middlewares);

    return this;
  }

  void discovery(Type controller) {
    ClassMirror controllerMirror = reflectClass(controller);
    var methods = controllerMirror.declarations.entries
        .where((element) =>
            !element.value.isPrivate && element.value is MethodMirror)
        .where((element) {
      return (element.value as MethodMirror).isConstructor == false;
    });
    var conventionalRoutes = {
      #index: {
        'methods': [RouteEntry.GET, RouteEntry.HEAD],
        'path': ''
      },
      #create: {
        'methods': [RouteEntry.GET],
        'path': 'create'
      },
      #show: {
        'methods': [RouteEntry.GET],
        'path': '{id}'
      },
      #store: {
        'methods': [RouteEntry.POST],
        'path': ''
      },
      #update: {
        'methods': [RouteEntry.PUT, RouteEntry.PATCH],
        'path': '{id}'
      },
      #delete: {
        'methods': [RouteEntry.DELETE],
        'path': '{id}'
      },
      #forceDelete: {
        'methods': [RouteEntry.DELETE],
        'path': '{id}/force'
      },
    };

    var order = conventionalRoutes.keys.toList();
    var conventionMethods = methods
        .where((e) => conventionalRoutes.keys.contains(e.key))
        .toList()
      ..sort((a, b) => order.indexOf(a.key) - order.indexOf(b.key));
    var otherMethods =
        methods.where((e) => !conventionalRoutes.keys.contains(e.key)).toList();

    Controller? metadata = _getAnnotationController(controllerMirror);

    middleware(metadata?.middleware).group(() {
      _registerRoutesForMethods(
          otherMethods, conventionalRoutes, controllerMirror, controller);
      _registerRoutesForMethods(
          conventionMethods, conventionalRoutes, controllerMirror, controller);
    });
  }

  Controller? _getAnnotationController(ClassMirror controller) {
    return controller.metadata
        .firstWhereOrNull((m) => m.reflectee is Controller)
        ?.reflectee;
  }

  void _registerRoutesForMethods(
    List<MapEntry<Symbol, DeclarationMirror>> methods,
    Map<Symbol, Map<String, Object>> conventionalRoutes,
    ClassMirror controllerMirror,
    Type controller,
  ) {
    methods.forEach((method) {
      var action = MirrorSystem.getName(method.key);
      var conventionalRoute = conventionalRoutes[method.key] ?? null;

      List<String> verbs = conventionalRoute != null
          ? conventionalRoute['methods'] as List<String>
          : _getVerbFromMethod(method.value);

      String resource =
          _getResourcePathFromControllerName(controllerMirror.simpleName);

      String routePath = conventionalRoute != null
          ? conventionalRoute['path'] as String
          : _getRoutePathFromSymbol(method.key);

      if (conventionalRoute != null) {
        routePath =
            _resolveConventionalRouteParam(method.value, routePath, action);
      } else {
        routePath = _buildRoutePathWithRouteParams(method.value, routePath);
      }

      var fullPath = '$resource/$routePath';

      var middleware = _getMiddlewaresFromRouteAnnotation(method);

      _registerRoute(verbs, fullPath, controller, action, resource, middleware);
    });
  }

  String _resolveConventionalRouteParam(
    DeclarationMirror method,
    String routePath,
    String action,
  ) {
    var firstParam = (method as MethodMirror)
        .parameters
        .where((param) => param.type.reflectedType != Request)
        .firstOrNull;

    if (routePath.contains('{id}') && firstParam == null) {
      throw ArgumentError('Parameter {id} not found for action [$action]');
    }

    if (routePath.contains('{id}')) {
      var paramName = MirrorSystem.getName(firstParam!.simpleName);
      routePath = routePath.replaceAll('{id}', "{$paramName}");
    }
    return routePath;
  }

  String _buildRoutePathWithRouteParams(
      DeclarationMirror method, String routePath) {
    var paramNames = (method as MethodMirror)
        .parameters
        .where((param) => param.type.reflectedType != Request)
        .map((param) => MirrorSystem.getName(param.simpleName))
        .map((name) => "{$name}")
        .toList()
        .join('/');
    return paramNames.isEmpty ? routePath : '$routePath/$paramNames';
  }

  dynamic _getMiddlewaresFromRouteAnnotation(
      MapEntry<Symbol, DeclarationMirror> method) {
    Route? metadata = _getAnnotationRouteFromMethod(method.value);
    return metadata?.middleware;
  }

  List<String> _getVerbFromMethod(DeclarationMirror method) {
    Route? metadata = _getAnnotationRouteFromMethod(method);
    var defaultVerbs = [RouteEntry.GET];

    if (metadata == null) return defaultVerbs;
    if (metadata.method != null) return [metadata.method!.toUpperCase()];

    return metadata.methods ?? defaultVerbs;
  }

  Route? _getAnnotationRouteFromMethod(DeclarationMirror method) {
    return method.metadata
        .firstWhereOrNull((m) => m.reflectee is Route)
        ?.reflectee;
  }

  String _getRoutePathFromSymbol(Symbol symbol) {
    return MirrorSystem.getName(symbol).paramCase;
  }

  String _getResourcePathFromControllerName(Symbol name) {
    return MirrorSystem.getName(name).paramCase.replaceAll('-controller', '');
  }

  RouteEntry _registerRoute(
    List<String> methods,
    String path,
    Type controller,
    String action,
    String resource,
    dynamic middleware,
  ) {
    return router
        .via(methods, path, controller, action)
        .middleware(middleware)
        .name('$resource.${action.paramCase}');
  }

  RouteEntry get(String path, handler, [String? action]) {
    return _set(path, handler, action)..register();
  }

  RouteEntry delete(String path, handler, [String? action]) {
    return _set(path, handler, action)..register();
  }

  RouteEntry patch(String path, handler, [String? action]) {
    return _set(path, handler, action)..register();
  }

  RouteEntry post(String path, handler, [String? action]) {
    return _set(path, handler, action)..register();
  }

  RouteEntry put(String path, handler, [String? action]) {
    return _set(path, handler, action)..register();
  }

  void register() {
    router.register(this);
  }

  RouteEntry mergeOptions(RouteOptions parentOptions) {
    options = options ?? RouteOptions();

    if (parentOptions.prefix != null) {
      var prefix = options!.prefix ?? '';
      options!.prefix = sanitize("${parentOptions.prefix}/${prefix}");
      _setPath(path);
    }

    if (parentOptions.name != null) {
      var name = options!.name ?? '';
      _name = options!.name = "${parentOptions.name}${name}";
    }

    if (parentOptions.middleware != null) {
      var parentMiddlewares = parentOptions.middleware is List
          ? parentOptions.middleware
          : [parentOptions.middleware];
      middlewares = [...parentMiddlewares, ...middlewares];
      middlewares.unique();
    }

    return this;
  }

  bool nameIs(String name) {
    return _name == name;
  }

  bool matches(Request request) {
    if (!methods.contains(request.method)) return false;
    if (sanitize(uri.path) == sanitize(request.uri.path)) return true;
    if (uri.pathSegments.length != request.uri.pathSegments.length)
      return false;

    return uri.pathSegments.every((segment) {
      if (_isParameter(segment)) return true;
      var index = uri.pathSegments.indexOf(segment);
      var requestSegment = request.uri.pathSegments.elementAt(index);

      return segment == requestSegment;
    });
  }

  String sanitize(String string) {
    return string.replaceAll(RegExp(r'^/*'), '').replaceAll(RegExp(r'/*$'), '');
  }

  run(Request request) async {
    request.setRoute(this);
    if (handler is Function) return _invokeFunction(request);
    if (hasController()) return _invokeController(request);

    throw UnsupportedError(
        'This type of RouteEntry handler is not supported. $handler');
  }

  _invokeFunction(Request request) {
    var mirror = reflect(request.route.handler) as ClosureMirror;

    var params = mirror.function.parameters.map((param) {
      var type = param.type.reflectedType;

      if (type == Request) return request;
      if (type == dynamic) type = String;
      if (_isPrimitive(type)) {
        return request.getRouteParam(param.simpleName, type: type);
      }

      return container.get(type);
    }).toList();

    return mirror.apply(params).reflectee;
  }

  _invokeController(Request request) {
    var controller = reflect(container.get(handler));
    var method = action!;

    return controller
        .invoke(
          Symbol(method),
          _injectedParams(controller, method, request),
        )
        .reflectee;
  }

  _injectedParams(InstanceMirror controller, String action, Request request) {
    MethodMirror? method = _getMethodFrom(controller, action);

    if (method == null) return [];

    return method.parameters.map((param) {
      var type = param.type.reflectedType;
      if (type == Request) return request;
      if (_isPrimitive(type)) {
        return paramValue(
          param.simpleName,
          request: request,
          castTo: type,
        );
      }

      return container.get(param.type.reflectedType);
    }).toList();
  }

  bool _isPrimitive(type) {
    return [int, double, String].contains(type);
  }

  MethodMirror? _getMethodFrom(InstanceMirror instance, String methodName) {
    return _getMethodsFrom(instance)
        .where((element) => element.key == Symbol(methodName))
        .toList()
        .firstOrNull
        ?.value as MethodMirror?;
  }

  Iterable<MapEntry<Symbol, DeclarationMirror>> _getMethodsFrom(
      InstanceMirror instance) {
    return instance.type.declarations.entries.where((declaration) =>
        declaration.value is MethodMirror && !declaration.value.isPrivate);
  }

  bool hasController() {
    var controller = reflectClass(handler);
    return controller.superclass!.reflectedType == Controller;
  }

  paramValue(
    Symbol paramName, {
    required Request request,
    required Type castTo,
  }) {
    var value =
        request.uri.pathSegments.elementAt(_paramIndexByName(paramName));

    if (castTo == int) return int.tryParse(value);
    if (castTo == double) return double.tryParse(value);

    return value;
  }

  String pathWith(dynamic params) {
    if (params == null && parameters.isEmpty) return uri.path;
    if (params == null && parameters.isNotEmpty)
      throw Exception("Missing route params ${parameters}");

    if (!_allowedParamTypes(params))
      throw Exception('Invalid param type for $params');
    if (!(params is List) && !(params is Map)) params = [params];
    if (params is Map) {
      var path = '/' +
          uri.pathSegments.map((segment) {
            if (!_isParameter(segment)) return segment;

            var paramName = _removeCurlyBraces(segment);
            if (params.isEmpty)
              throw ArgumentError("Missing route param '$paramName'");

            var paramValue = params[paramName];
            if (paramValue != null)
              (params as Map).removeWhere((key, value) => key == paramName);
            return paramValue;
          }).join('/');

      if (params.isNotEmpty) {
        String queryParams = Uri(
          queryParameters: params as Map<String, dynamic>,
        ).query;

        return "$path?$queryParams";
      }

      return path;
    }

    return '/' +
        uri.pathSegments.map((segment) {
          if (!_isParameter(segment)) return segment;

          var index = parameters.indexOf(segment);
          return params[index];
        }).join('/');
  }

  bool _allowedParamTypes(params) {
    return [int, double, String].any((type) => params.runtimeType == type) ||
        params is List ||
        params is Map;
  }

  int _paramIndexByName(Symbol paramName) {
    return uri.pathSegments.indexOf(_paramByName(paramName));
  }

  String _paramByName(Symbol paramName) {
    return parameters.firstWhere(
      (segment) => Symbol(_removeCurlyBraces(segment)) == paramName,
    );
  }

  bool _isParameter(String segment) {
    return segment.startsWith('{') && segment.endsWith('}');
  }

  String _removeCurlyBraces(String segment) {
    return segment.replaceAll(RegExp(r'[{}]*'), '');
  }

  RouteEntry _set(String path, handler, String? action) {
    _setPath(path);
    this.handler = handler;
    this.action = action;

    return this;
  }

  RouteEntry setOption({String? prefix, String? name, dynamic middleware}) {
    if (options == null) options = RouteOptions();

    if (prefix != null) options!.prefix = prefix;
    if (name != null) options!.name = name;
    if (middleware != null) {
      options!.middleware = middleware;
      if (middleware is List)
        middlewares.addAll(middleware);
      else if (middleware is Type || middleware is String)
        middlewares.add(middleware);
      else
        throw ArgumentError('Invalid type for middleware $middleware');
      middlewares.unique();
    }

    return this;
  }

  _getOption(option) {
    if (options == null) return;

    return reflect(options).getField(Symbol(option)).reflectee;
  }

  RouteEntry _setPath(String path) {
    String? prefix = _getOption('prefix');

    this.path = prefix != null ? "${sanitize(prefix)}/${sanitize(path)}" : path;

    return this;
  }
}
