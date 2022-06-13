import 'package:test/test.dart';
import 'package:tunder/utils.dart';

main() {
  group('Random', () {
    test('.id() generates unique string ID with 16 characters', () {
      final id = Generate.id();
      expect(id.length, 16);
      expect(id, isNot(equals(Generate.id(16))));
    });

    test('.id(length) generates unique string ID with given length', () {
      final id = Generate.id(10);
      expect(id.length, 10);
      expect(id, isNot(equals(Generate.id(10))));
    });

    test('.password() generates a password of 32 characters', () {
      final password = Generate.password();
      expect(password.length, 32);
      expect(password, isNot(equals(Generate.password())));
    });

    test('.password(length) generates a password of given length', () {
      final password = Generate.password(10);
      expect(password.length, 10);
      expect(password, isNot(equals(Generate.password(10))));
    });
  });
}
