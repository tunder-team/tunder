abstract class Migration {
  abstract final String id;
  abstract final String name;
  Future up();
  Future down();
}
