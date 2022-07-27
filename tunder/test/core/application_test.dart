import 'package:tunder/http.dart';
import 'package:tunder/src/core/binding_resolution_exception.dart';
import 'package:tunder/src/core/container.dart';
import 'package:tunder/contracts.dart' as Contract;
import 'package:tunder/src/console/console_kernel.dart';
import 'package:test/test.dart';
import 'package:tunder/tunder.dart';

class A {
  A();

  factory A.from() {
    return A();
  }

  someMethod() {
    return 'some method called';
  }
}

class B {
  B();
}

class C {
  final A a;
  final B b;

  C(this.a, this.b);
}

abstract class D {}

class UnresolvableClass {
  final D abstractProperty;

  UnresolvableClass({required this.abstractProperty});
}

main() {
  group('App class', () {
    test('is a Container', () {
      var app = Application();
      expect(app, TypeMatcher<Container>());
    });

    test('is a singleton', () {
      var app = Application();
      expect(app, Application());
      expect(app, Application());
      expect(app, Application());
    });

    test('Singleton method', () {
      var count = 0;
      var app = Application();
      app.singleton('increment', (_) {
        count++;

        return count;
      });
      var once = app.get('increment');

      expect(once, TypeMatcher<int>());
      expect(once, 1);
      expect(app.get('increment'), 1);
      expect(app.get('increment'), 1);
    });

    test('HttpKernel singleton', () {
      var app = Application();
      app.singleton(
          Contract.HttpKernelContract, (app) => Kernel(app, app.get(Router)));

      Contract.HttpKernelContract kernel = app.get(Contract.HttpKernelContract);
      Contract.HttpKernelContract kernel2 =
          app.get(Contract.HttpKernelContract);

      expect(kernel, TypeMatcher<Contract.HttpKernelContract>());
      expect(identical(kernel, kernel2), isTrue);
      expect(kernel, kernel2);
      expect(kernel == kernel2, isTrue);
    });

    test('Singleton with function', () {
      var app = Application();
      int count = 0;

      app.singleton(Kernel, (_) {
        count++;
        return Kernel(app, app.get(Router));
      });
      var kernel = app.getSafe(Kernel);
      var kernel2 = app.getSafe(Kernel);
      expect(kernel, TypeMatcher<Kernel>());
      expect(kernel, kernel2);
      expect(kernel == kernel2, isTrue);
      expect(count, 1);
    });

    group('.get() method', () {
      test('resolves a class when argument is a Type', () {
        var app = Application();
        var a = app.get(A);

        expect(a, TypeMatcher<A>());
      });

      test('resolves a class if registered', () {
        var app = Application();
        app.bind(A, B);
        var a = app.get(A);
        expect(a, TypeMatcher<B>());

        app.bind('a', A);
        var a2 = app.get('a');
        expect(a2, TypeMatcher<A>());
      });

      test('resolves a not registered class if all dependencies are resolvable',
          () {
        var app = Application.create();
        var c = app.get(C);

        expect(c, TypeMatcher<C>());
      });

      test(
          'resolves a contract (abstract class) if there is a registered class for the interface',
          () {
        var app = Application.create();
        app.bind(D, C);
        var d = app.get(D);

        expect(d, TypeMatcher<C>());
      });

      test('resolves a class with same name but different files', () {
        var app = Application();
        app.bind(Contract.HttpKernelContract, Kernel);
        app.bind(Contract.ConsoleKernelContract, ConsoleKernel);

        var httpKernel = app.get(Contract.HttpKernelContract);
        var consoleKernel = app.get(Contract.ConsoleKernelContract);

        expect(httpKernel, TypeMatcher<Contract.HttpKernelContract>());
        expect(consoleKernel, TypeMatcher<Contract.ConsoleKernelContract>());
      });

      test('it doesnt duplicate with same key', () {
        var app = Application();
        app.bind(Contract.HttpKernelContract, 'jetete');
        app.bind(Contract.HttpKernelContract, 'overwrite');

        var kernel = app.get(Contract.HttpKernelContract);

        expect(kernel, 'overwrite');
      });

      test(
          "throws a binding resolution exception if can't find a binding for a string key",
          () {
        var app = Application();
        expect(() => app.get('something'),
            throwsA(TypeMatcher<BindingResolutionException>()));
      });

      test(
          "throws a binding resolution error if can't find a binding for an abstract class",
          () {
        var app = Application.create();
        expect(() => app.get(Contract.HttpKernelContract),
            throwsA(TypeMatcher<BindingResolutionException>()));
      });

      test(
          "throws a binding resolution error if can't find a binding for a unresolvable dependency",
          () {
        var app = Application.create();
        expect(() => app.get(UnresolvableClass),
            throwsA(TypeMatcher<BindingResolutionException>()));
      });
    });

    test('.get() with different contracts with same name resolution', () {
      var app = Application();
      app.bind(Contract.HttpKernelContract, Kernel);
      app.bind(Contract.ConsoleKernelContract, ConsoleKernel);

      Contract.HttpKernelContract httpKernel =
          app.get<Contract.HttpKernelContract>(Contract.HttpKernelContract);
      Contract.ConsoleKernelContract consoleKernel = app
          .get<Contract.ConsoleKernelContract>(Contract.ConsoleKernelContract);

      expect(httpKernel, TypeMatcher<Kernel>());
      expect(consoleKernel, TypeMatcher<ConsoleKernel>());
    });

    test('automatic ioc with get', () {
      var app = Application();
      app.bind(Contract.HttpKernelContract, Kernel);
      Contract.HttpKernelContract kernel = app.get(Contract.HttpKernelContract);
      expect(kernel, TypeMatcher<Contract.HttpKernelContract>());
    });

    test(
        '.boot() -> it loads all service providers registered in the Http Kernel',
        () {
      var app = Application();
      Kernel kernel = app.get(Kernel);
      app.bind(Contract.HttpKernelContract, kernel);

      kernel.providers.addAll([MyServiceProvider()]);

      app.boot();

      expect(app.get('my.service'), 'it worked');
    });

    test('.flush() -> resets the singleton instance', () {
      var app = Application();
      var app2 = Application();
      expect(identical(app, app2), true);
      app.flush();
      app2 = Application();
      expect(identical(app, app2), false);
    });
  });
}

class MyServiceProvider extends ServiceProvider {
  @override
  boot(Application app) {
    app.bind('my.service', 'it worked');
  }
}
