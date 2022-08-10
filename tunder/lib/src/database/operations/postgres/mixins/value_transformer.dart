mixin PostgresTransformers {
  String transformValue(value) {
    if (value is DateTime) return "'${value.toIso8601String()}'";
    if (value is num) return '$value';
    if (value is bool) return value ? 'true' : 'false';

    return "'$value'";
  }

  String toIdentity(name) => '"$name"';

  Function(Map map) toField(name) => (map) => map[name];
}
