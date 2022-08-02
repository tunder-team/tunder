import 'package:tunder_cli/tunder_cli.dart';

void main(List<String> args) async {
  var runner = TunderCommandRunner();
  await runner.run(args);
}
