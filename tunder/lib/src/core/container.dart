import 'dart:mirrors';

import 'package:tunder/src/core/binding_resolution_exception.dart';

class Container {
  final Map _bindingMap = {};

  void bind(key, value, {bool shared = false}) {
    _bindingMap[key] = {'value': value, 'shared': shared};
  }

  void singleton(key, value) => bind(key, value, shared: true);

  T get<T>(key) {
    Map? binding = _bindingMap[key];

    if (binding == null && key is Type) {
      return _resolveType(key);
    }

    if (binding == null) throw BindingResolutionException();
    if (binding['instance'] != null) return binding['instance'];

    var value = binding['value'];

    value = value is Function ? value(this) : value;

    if (value is Type) value = _resolveType(value);
    if (binding['shared']) binding['instance'] = value;

    return value;
  }

  T? getSafe<T>(key) {
    try {
      return get<T>(key);
    } on BindingResolutionException {
      return null;
    }
  }

  _resolveType(Type type) {
    var mirror = reflectClass(type);

    if (mirror.isAbstract) throw BindingResolutionException();

    var constructor = _getDefaultConstructor(mirror);

    var positionalArguments = constructor!.parameters
        .where((param) => !param.isNamed)
        .map((param) => get(param.type.reflectedType))
        .toList();

    var namedArguments = <Symbol, dynamic>{};
    constructor.parameters.where((param) => param.isNamed).forEach((param) {
      namedArguments[param.simpleName] = get(param.type.reflectedType);
    });

    var instance =
        mirror.newInstance(constructor.constructorName, positionalArguments);

    return instance.reflectee;
  }

  MethodMirror? _getDefaultConstructor(ClassMirror mirror) =>
      mirror.declarations.values
          .where((m) => m is MethodMirror && m.isConstructor)
          .firstWhere(
            (constructor) => constructor.simpleName == mirror.simpleName,
          ) as MethodMirror;
}
