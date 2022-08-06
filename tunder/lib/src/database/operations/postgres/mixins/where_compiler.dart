import 'package:tunder/src/database/where.dart';

mixin WhereCompiler {
  String compileSelectedColumns(String table, List<String> columns) {
    if (columns.isEmpty) return '*';
    if (columns.length == 1 && columns.first == '*') return '*';

    return columns.map((c) => '"$table"."$c"').join(', ');
  }

  String compileWhereClauses(List<Where> wheres) {
    var sql = wheres.map(_compileWhere).join(' ').trim();
    if (sql.startsWith('AND ') || sql.startsWith('(AND'))
      sql = sql.replaceFirst('AND ', '');
    if (sql.startsWith('OR ') || sql.startsWith('(OR'))
      sql = sql.replaceFirst('OR ', '');

    return sql.trim();
  }

  String _compileWhere(Where where) {
    String sql = _compileSingleWhere(where);
    String otherClauses = where.wheres
        .map(_compileWhere)
        .join(' ${where.boolOperator.toUpperCase()} ');

    if (otherClauses.isEmpty) return sql;
    if (otherClauses.startsWith('(')) {
      otherClauses = otherClauses.substring(1, otherClauses.length - 1);
    }

    return "($sql $otherClauses)";
  }

  String _compileSingleWhere(Where where) {
    final column = '"${where.column}"';
    final operator = where.operator;
    final boolOperator = where.boolOperator;
    final value = where.value;

    if (operator == 'IS NOT NULL') return "$boolOperator $column $operator";
    if (value == null) return "$boolOperator $column IS NULL";
    if (value is num) return "$boolOperator $column $operator $value";
    if (value is List) {
      if (value.every((element) => element is num)) {
        return where.operator == 'BETWEEN'
            ? "$boolOperator $column $operator ${value.join(' AND ')}"
            : "$boolOperator $column $operator (${value.join(', ')})";
      }

      var newValue = value.map((v) => "\$\$${v}\$\$");

      if (value.every((element) => element is DateTime)) {
        return ['BETWEEN', 'NOT BETWEEN'].contains(where.operator)
            ? "$boolOperator $column $operator ${newValue.join(' AND ')}"
            : "$boolOperator $column $operator (${newValue.join(', ')})";
      }

      return "$boolOperator $column $operator (${newValue.join(', ')})";
    }

    if (value is bool && ['IS TRUE', 'IS FALSE'].contains(where.operator))
      return "$boolOperator $column $operator";

    if (value is bool) return "$boolOperator $column $operator $value";

    return "$boolOperator $column $operator \$\$$value\$\$";
  }
}
