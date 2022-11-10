import 'dart:async';
import 'dart:io';

import 'package:tunder/src/http/request.dart';
import 'package:tunder/src/http/response.dart';
import 'package:tunder/src/http/route_entry.dart';
import 'package:tunder/src/http/router.dart';
import 'package:tunder/tunder.dart';
import 'package:tunder/contracts.dart' as Contract;

class Kernel implements Contract.HttpKernelContract {
  final Application app;
  final Router router;
  final List<ServiceProvider> providers = [];
  final List middlewares = [];
  Map<String, Type> routeMiddlewares = {};

  Kernel(this.app, this.router) {
    syncMiddlewaresToRouter();
  }

  @override
  Future<void> handle(HttpRequest baseRequest) async {
    Request request = Request.fromBase(baseRequest)..container = app;
    await _processRequest(request);
  }

  FutureOr<void> _processRequest(Request request) async {
    await request.complete();
    Response response = Response.from(request);

    try {
      RouteEntry? route = request.findRoute();
      if (route == null) Response.notFound();

      var response = await router.runRoute(request, route);

      response.write();
    } on HttpException catch (error) {
      response.statusCode = error.statusCode;
    } catch (e, s) {
      response.statusCode = 500;
      response.write('Error: $e\nStack trace:\n$s');
    } finally {
      response.close(request);
    }
  }

  syncMiddlewaresToRouter() {
    router.middlewares.addAll(middlewares);
    router.aliasMiddleware.addAll(routeMiddlewares);
  }
}
