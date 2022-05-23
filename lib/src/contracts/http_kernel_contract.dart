import 'dart:io';

abstract class HttpKernelContract {
  List<Type> providers = [];

  Future<void> handle(HttpRequest request);
}
