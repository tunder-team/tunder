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

  Where greaterThan(value) {
    this.value = value;
    this.operator = '>';

    return this;
  }

  Where greaterThanOrEqual(value) {
    this.value = value;
    this.operator = '>=';

    return this;
  }

  Where lessThan(value) {
    this.value = value;
    this.operator = '<';

    return this;
  }

  Where lessThanOrEqual(value) {
    this.value = value;
    this.operator = '<=';

    return this;
  }

  /**
   * Alias of [isIn]. Builds a WHERE IN query.
   */
  Where inList(List<dynamic> values) {
    return isIn(values);
  }

  /**
   * Builds a WHERE IN query.
   */
  Where isIn(List<dynamic> values) {
    this.value = values;
    this.operator = 'IN';

    return this;
  }

  /**
   * Alias of [notIn]. Builds a WHERE NOT IN query.
   */
  Where isNotIn(List<dynamic> values) {
    return notIn(values);
  }

  /**
   * Builds a WHERE NOT IN query.
   */
  Where notIn(List<dynamic> values) {
    this.value = values;
    this.operator = 'NOT IN';

    return this;
  }

  Where between(dynamic from, dynamic to) {
    this.value = [from, to];
    this.operator = 'BETWEEN';

    return this;
  }

  Where notBetween(dynamic from, dynamic to) {
    this.value = [from, to];
    this.operator = 'NOT BETWEEN';

    return this;
  }

  Where get isTrue {
    this.value = true;
    this.operator = 'IS TRUE';

    return this;
  }

  Where get isFalse {
    this.value = false;
    this.operator = 'IS FALSE';

    return this;
  }

  Where get isNotNull {
    this.operator = 'IS NOT NULL';

    return this;
  }

  Where get isNull {
    this.operator = 'IS NULL';

    return this;
  }

  Where isNot(value) {
    this.value = value;
    this.operator = 'IS NOT';

    return this;
  }

  /**
   * Alias for [caseInsensitive].
   */
  Where get insensitive => caseInsensitive;
  Where get caseInsensitive {
    this.operator = 'ILIKE';

    return this;
  }

  String toSql() {
    if (operator == 'IS NOT NULL') return "$boolOperator $column $operator";
    if (value == null) return "$boolOperator $column IS NULL";
    if (value is num) return "$boolOperator $column $operator $value";
    if (value is List) {
      if ((value as List).every((element) => element is num)) {
        return this.operator == 'BETWEEN'
            ? "$boolOperator $column $operator ${value.join(' AND ')}"
            : "$boolOperator $column $operator (${value.join(', ')})";
      }

      var newValue = value.map((v) => "\$\$${v}\$\$");

      if ((value as List).every((element) => element is DateTime)) {
        return ['BETWEEN', 'NOT BETWEEN'].contains(this.operator)
            ? "$boolOperator $column $operator ${newValue.join(' AND ')}"
            : "$boolOperator $column $operator (${newValue.join(', ')})";
      }

      return "$boolOperator $column $operator (${newValue.join(', ')})";
    }

    if (value is bool && ['IS TRUE', 'IS FALSE'].contains(this.operator))
      return "$boolOperator $column $operator";

    if (value is bool) return "$boolOperator $column $operator $value";

    return "$boolOperator $column $operator \$\$$value\$\$";
  }
}
