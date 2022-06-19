class Constraint {
  final String type;
  final String table;
  List<String> columns;
  String? name;
  String? expression;

  Constraint(
    this.type, {
    required this.table,
    this.columns = const [],
    this.expression,
    this.name,
  });
}

class UniqueConstraint extends Constraint {
  UniqueConstraint({
    required String table,
    required List<String> columns,
    String? name,
  }) : super(
          ConstraintType.unique,
          table: table,
          columns: columns,
          name: name,
        );
}

class PrimaryConstraint extends Constraint {
  PrimaryConstraint({
    required String table,
    List<String> columns = const [],
    String? name,
  }) : super(
          ConstraintType.primary,
          table: table,
          columns: columns,
          name: name,
        );
}

class ConstraintType {
  static const String notNull = 'not null';
  static const String unique = 'unique';
  static const String primary = 'primary key';
  static const String foreign = 'foreign key';
  static const String check = 'check';
}
