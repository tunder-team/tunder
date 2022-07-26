class RouteNotFoundException extends ArgumentError implements Exception {
  String message;

  RouteNotFoundException(this.message);
}
