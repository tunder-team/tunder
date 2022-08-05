class BindingResolutionException implements Exception {
  final key;
  const BindingResolutionException(this.key);

  String toString() => 'Failed to resolve binding for: [$key]';
}
