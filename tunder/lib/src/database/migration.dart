abstract class Migration {
  abstract final int version;
  abstract final String name;
  Future up();
  Future down();
}
