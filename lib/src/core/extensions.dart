import 'dart:mirrors';

extension tunderInt on int {
  Duration get week => Duration(days: this * 7);
  Duration get weeks => Duration(days: this * 7);

  Duration get day => Duration(days: this);
  Duration get days => Duration(days: this);

  Duration get hour => Duration(hours: this);
  Duration get hours => Duration(hours: this);

  Duration get minute => Duration(minutes: this);
  Duration get minutes => Duration(minutes: this);

  Duration get second => Duration(seconds: this);
  Duration get seconds => Duration(seconds: this);

  Duration get millisecond => Duration(milliseconds: this);
  Duration get milliseconds => Duration(milliseconds: this);

  Duration get microsecond => Duration(microseconds: this);
  Duration get microseconds => Duration(microseconds: this);
}

extension tunderDurations on Duration {
  Future<void> get delay => Future.delayed(this);

  DateTime get fromNow => DateTime.now().add(this);
  DateTime get later => DateTime.now().add(this);

  DateTime get ago => DateTime.now().subtract(this);
}

extension Trimmer on String {
  String trimWith(String pattern) {
    RegExp leading = RegExp('^[$pattern]*');
    RegExp trailing = RegExp('/*[${pattern}]\$');

    return trim().replaceAll(leading, '').replaceAll(trailing, '');
  }
}

extension Name on Symbol {
  String get name => MirrorSystem.getName(this);
}

extension Unique<E, Id> on List<E> {
  /**
   * Mutates the list with unique values preserving the order.
   *
   * Example:
   *
   * ```dart
   * var list = [1, 2, 3, 4, 3, 2, 4, 5];
   * list.unique();
   * print(list); // [1, 2, 3, 4, 5]
   * ```
   *
   * Can be used with an identifier:
   *
   * ```dart
   * var users = [User(1), User(2), User(1)];
   * users.unique((u) => u.id);
   * print(users); // [User(1), User(2)]
   * ```
   */
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final uniqueSet = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => uniqueSet.add(id != null ? id(x) : x as Id));
    return list;
  }
}

abstract class Extensions {}

abstract class tunderExtensions {}
