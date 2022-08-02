class IndexSchema {
  final String name;
  final String column;
  final String table;
  final List<String> columns;

  IndexSchema({
    required this.column,
    required this.table,
    this.columns = const [],
    name,
  }) : this.name = name ?? '${table}_${column}_index';

  toString() => name;
}
