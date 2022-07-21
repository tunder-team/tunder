import 'dart:io';

import 'package:tunder/src/core/service_provider.dart';

abstract class HttpKernelContract {
  final List<ServiceProvider> providers = [];

  Future<void> handle(HttpRequest request);
}
