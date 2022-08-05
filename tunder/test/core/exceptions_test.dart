import 'package:test/test.dart';
import 'package:tunder/src/core/binding_resolution_exception.dart';

main() {
  group('Exceptions', () {
    test('BindingResolutionException', () {
      expect(BindingResolutionException('key').toString(),
          'Failed to resolve binding for: [key]');
    });
  });
}
