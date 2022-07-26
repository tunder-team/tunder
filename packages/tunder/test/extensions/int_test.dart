import 'package:test/test.dart';
import 'package:tunder/tunder.dart';

main() {
  group('TunderInt extension:', () {
    var testCases = {
      '1.week': [1.week, Duration(days: 7)],
      '2.weeks': [2.weeks, Duration(days: 14)],
      '1.day': [1.day, Duration(days: 1)],
      '2.days': [2.days, Duration(days: 2)],
      '1.hour': [1.hour, Duration(hours: 1)],
      '2.hours': [2.hours, Duration(hours: 2)],
      '1.minute': [1.minute, Duration(minutes: 1)],
      '2.minutes': [2.minutes, Duration(minutes: 2)],
      '1.second': [1.second, Duration(seconds: 1)],
      '2.seconds': [2.seconds, Duration(seconds: 2)],
      '1.millisecond': [1.millisecond, Duration(milliseconds: 1)],
      '2.milliseconds': [2.milliseconds, Duration(milliseconds: 2)],
      '1.microsecond': [1.microsecond, Duration(microseconds: 1)],
      '2.microseconds': [2.microseconds, Duration(microseconds: 2)],
    };

    testCases.forEach((testName, testCase) {
      var input = testCase[0];
      var expected = testCase[1];
      test('$testName returns duration of $expected', () {
        expect(input, expected);
      });
    });
  });
}
