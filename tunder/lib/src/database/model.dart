import 'dart:mirrors';
import 'package:tunder/extensions.dart';

abstract class Model<T> {
  T fill(Map<String, dynamic> attributes) {
    var model = InstanceReflection(this);
    model.properties
        .where((property) => attributes.containsKey(property.name))
        .forEach((property) => model.setProperty(
            property.name, _cast(property, attributes[property.name])));
    return this as T;
  }

  dynamic _cast(PropertyReflection property, value) {
    if (value is! String) return value;

    if (property.type == int) return int.parse(value);
    if (property.type == DateTime) return DateTime.parse(value);

    return value;
  }
}

class InstanceReflection {
  final Object instance;
  late ClassMirror classMirror;
  late InstanceMirror instanceMirror;
  late TypeMirror typeMirror;

  InstanceReflection(this.instance) {
    typeMirror = reflectType(instance.runtimeType);
    classMirror = reflectClass(instance.runtimeType);
    instanceMirror = reflect(instance);
  }

  List<PropertyReflection> get properties => classMirror.declarations.values
      .where((declaration) => declaration is VariableMirror)
      .map((declaration) =>
          PropertyReflection(declaration as VariableMirror, this))
      .toList();

  void setProperty(String propertyName, dynamic value) => properties
      .firstWhere((property) => property.name == propertyName)
      .set(value);
}

class PropertyReflection {
  final VariableMirror mirror;
  final InstanceReflection? instance;

  PropertyReflection(this.mirror, [this.instance]);

  String get name => mirror.simpleName.name;
  Type get type => mirror.type.reflectedType;

  set(dynamic value) => instance?.instanceMirror.setField(Symbol(name), value);
}
