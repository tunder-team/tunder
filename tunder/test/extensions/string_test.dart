import 'package:test/test.dart';
import 'package:tunder/tunder.dart';

main() {
  group('TunderString extension', () {
    test('trimWith(pattern) trim leading and trailing pattern on a string', () {
      expect(';abc;'.trimWith(';'), 'abc');
      expect('abc; '.trimWith(';'), 'abc');
      expect(' ; abc ; '.trimWith(';'), 'abc');
    });

    test('.shuffle() randomizes a string', () {
      var str = 'abcdefghijklmnopqrstuvwxyz';
      expect(str.shuffle(), isNot(str));
    });
  });
}
