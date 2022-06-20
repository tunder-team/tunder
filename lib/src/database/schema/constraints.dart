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

class NotNullConstraint extends Constraint {
  NotNullConstraint({required String table, required String column})
      : super(ConstraintType.notNull, table: table, columns: [column]);
}

class NullableConstraint extends Constraint {
  NullableConstraint({required String table, required String column})
      : super(ConstraintType.nullable, table: table, columns: [column]);
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
  static const String nullable = 'null';
  static const String unique = 'unique';
  static const String primary = 'primary key';
  static const String foreign = 'foreign key';
  static const String check = 'check';
}
