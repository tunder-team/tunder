import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:tunder/tunder.dart';
import 'package:tunder/contracts.dart';
import 'package:tunder/src/http/router.dart';

import 'container.dart';

class Application extends Container {
  static Application? _instance;
  static HttpServer? server;

  factory Application({String? basePath, String? baseUrl}) {
    if (_instance == null) {
      _instance = create();
      _instance!
          .init(basePath: basePath ?? Directory.current.path, baseUrl: baseUrl);
    }

    return _instance!;
  }

  Application._();

  static Application create() {
    return Application._();
  }

  Future<HttpServer> serve({int port = 8000}) async {
    final DotEnv dotenv = DotEnv();
    var uri = Uri.parse(dotenv['APP_URL'] ?? 'http://localhost:$port');

    if (server != null) {
      await server!.close(force: true);
    }

    server = await HttpServer.bind(uri.host, uri.port);
    var baseUrl = 'http://${server!.address.host}:${server!.port}';

    setBaseUrl(baseUrl);
    print('\n[Serving] at $baseUrl');
    serveRequests(server!);

    return server!;
  }

  void serveRequests(Stream<HttpRequest> requests) {
    requests.listen((request) {
      print('[Request] ${request.method} ${request.uri.path}');
      handleRequest(request);
    });
  }

  Future<void> handleRequest(HttpRequest baseRequest) async {
    HttpKernelContract kernel = get(HttpKernelContract);
    await kernel.handle(baseRequest);
  }

  init({required String basePath, String? baseUrl}) {
    setBasePaths(basePath);
    setBaseUrl(baseUrl);
    _registerBaseSingletons();
  }

  boot() {
    _bootProviders();
  }

  flush() {
    Application._instance = null;
  }

  _registerBaseSingletons() {
    singleton(Application, this);
    singleton(Router, Router(this));
  }

  _bootProviders() {
    HttpKernelContract kernel = get(HttpKernelContract);
    kernel.providers.forEach((providerType) {
      var provider = get<ServiceProvider>(providerType);
      provider.boot(this);
    });
  }

  setBasePaths(String basePath) {
    bind('root.path', basePath);
    bind('url.path', 'http://localhost:8000');
    bind('app.path', "$basePath/app");
    bind('config.path', "$basePath/config");
    bind('lib.path', "$basePath/lib");
    bind('routes.path', "$basePath/routes");
    bind('public.path', "$basePath/public");
    bind('bootstrap.path', "$basePath/bootstrap");
    bind('database.path', "$basePath/database");
    bind('storage.path', "$basePath/storage");
  }

  setBaseUrl(String? baseUrl) {
    bind('app.url', baseUrl ?? 'http://localhost:8000');
  }
}
