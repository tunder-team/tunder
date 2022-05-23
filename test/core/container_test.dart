import 'package:tunder/contracts.dart';
import 'package:tunder/src/core/container.dart';
import 'package:tunder/src/http/kernel.dart';
import 'package:test/test.dart';

class A {
  name() {
    return 'A';
  }
}

void main() {
  group('Container class', () {
    var container = Container();

    test('can create multiple instances', () {
      var container = Container();
      var container2 = Container();

      expect(container, TypeMatcher<Container>());
      expect(container2, TypeMatcher<Container>());
      expect(container, isNot(container2));
    });

    test('.bind() can bind a string key to a value', () {
      container.bind('A', (_) => new A());
      var a = container.get<A>('A');
      var a2 = container.get('A');
      expect(a, TypeMatcher<A>());
      expect(a, isNot(a2));
    });

    test('.bind() can bind a class to a value', () {
      container.bind(A, (_) => new A());
      var a = container.get(A);
      var a2 = container.get(A);
      expect(a, TypeMatcher<A>());
      expect(a, isNot(a2));
    });

    test('.singleton() binds one instance once', () {
      container.singleton(A, (_) => new A());
      var a = container.get(A);
      var a2 = container.get(A);

      expect(a, TypeMatcher<A>());
      expect(a2, TypeMatcher<A>());
      expect(a, a2);
    });
  });
}
