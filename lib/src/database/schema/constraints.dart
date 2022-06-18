class Constraint {
  final String type;
  final String table;
  String? column;
  late String name;

  Constraint(
    this.type, {
    required this.table,
    this.column,
    String? name,
  }) {
    if (name == null && column == null)
      throw ArgumentError(
          '[name] or [column] should be specified but both are null.');

    this.name = name ?? '${table}_${column}_${type}';
  }

  toString() => name;
}

class UniqueConstraint extends Constraint {
  UniqueConstraint({required String table, String? column, String? name})
      : super(ConstraintType.unique, table: table, column: column, name: name);
}

class ConstraintType {
  static const String notNull = 'not_null';
  static const String unique = 'unique';
  static const String primary = 'pkey';
  static const String foreign = 'fkey';
  static const String check = 'check';
  static const String default_ = 'default';
}
