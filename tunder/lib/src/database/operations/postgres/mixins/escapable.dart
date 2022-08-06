mixin ValueTransformer {
  String transform(value) {
    if (value is DateTime) return "'${value.toIso8601String()}'";
    if (value is num) return '$value';
    if (value is bool) return value ? 'true' : 'false';

    return "'$value'";
  }
}
