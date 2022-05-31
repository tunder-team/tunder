class Where {
  final String column;
  String boolOperator;
  String operator = '=';
  dynamic value;

  Where(this.column, {this.boolOperator = 'AND'});

  Where equals(value) {
    this.value = value;

    return this;
  }

  Where different(value) {
    this.value = value;
    this.operator = '!=';

    return this;
  }

  Where notEqual(value) {
    return different(value);
  }

  Where contains(value) {
    this.value = '%$value%';
    this.operator = 'LIKE';

    return this;
  }

  Where endsWith(value) {
    this.value = '%$value';
    this.operator = 'LIKE';

    return this;
  }

  Where startsWith(value) {
    this.value = '$value%';
    this.operator = 'LIKE';

    return this;
  }

  Where get isNotNull {
    this.operator = 'IS NOT NULL';

    return this;
  }

  String toSql() {
    if (value is String) return "$boolOperator $column $operator '$value'";
    if (operator == 'IS NOT NULL') return "$boolOperator $column $operator";
    if (value == null) return "$boolOperator $column IS NULL";
    return "$boolOperator $column $operator $value";
  }
}
