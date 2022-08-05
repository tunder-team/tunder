abstract class ConsoleKernelContract {
  Future<int> handle(List<String> args);
  List<Type> commands();
}
