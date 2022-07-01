import 'package:test/test.dart';
import 'package:tunder/extensions.dart';

main() {
  group('TunderDuration extension:', () {
    test('1.day.fromNow -> returns a datetime equivalent', () {
      var now = DateTime.now();
      var expected = now.add(Duration(days: 1));
      var result = 1.day.fromNow;
      expect(result.day, expected.day);
      expect(result.month, expected.month);
      expect(result.year, expected.year);
      expect(result.hour, expected.hour);
    });

    test('1.day.later -> returns a datetime equivalent', () {
      var now = DateTime.now();
      var expected = now.add(Duration(days: 1));
      var result = 1.day.later;
      expect(result.day, expected.day);
      expect(result.month, expected.month);
      expect(result.year, expected.year);
      expect(result.hour, expected.hour);
    });

    test('1.day.ago -> returns a datetime equivalent', () {
      var now = DateTime.now();
      var expected = now.subtract(Duration(days: 1));
      var result = 1.day.ago;
      expect(result.day, expected.day);
      expect(result.month, expected.month);
      expect(result.year, expected.year);
      expect(result.hour, expected.hour);
    });
  });
}
