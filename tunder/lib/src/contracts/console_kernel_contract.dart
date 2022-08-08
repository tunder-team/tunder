import 'package:tunder/database.dart';

abstract class ConsoleKernelContract {
  Future<int> handle(List<String> args);
  List<Type> commands();
  List<Migration> migrations();
}
