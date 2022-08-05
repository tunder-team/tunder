import 'package:tunder/src/http/route_entry.dart';

abstract class RouteDefinitions {
  RouteEntry get(String path, handler, [String? action]);
  RouteEntry post(String path, handler, [String? action]);
  RouteEntry put(String path, handler, [String? action]);
  RouteEntry delete(String path, handler, [String? action]);
  RouteEntry patch(String path, handler, [String? action]);
}
