import 'package:test/test.dart';
import 'package:tunder/console.dart';
import 'package:tunder/utils.dart';

main() {
  group('ConsoleKernel', () {
    test('handle(args)', () async {
      ConsoleKernel kernel = app().get(ConsoleKernel);
      var exitCode = await kernel.handle([]);

      expect(exitCode, 0);
    });
  });
}
