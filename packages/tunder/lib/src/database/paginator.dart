import 'package:tunder/database.dart';

class Paginator<T> {
  int page;
  int perPage;
  Query<T> query;

  Paginator({
    required this.query,
    required this.page,
    required this.perPage,
  });

  Future<Pagination<T>> get() async {
    var query = _paginated;

    var result = await Future.wait([
      query.get(),
      query.count(),
    ]);

    List<T> data = result[0] as List<T>;
    var total = result[1] as int;
    var from = (page - 1) * perPage + 1;
    var lastPage = (total / perPage).ceil();

    return Pagination<T>(
      currentPage: page,
      perPage: perPage,
      total: total,
      data: data,
      from: from,
      to: from + data.length - 1,
      lastPage: lastPage,
    );
  }

  String toSql() {
    return _paginated.toSql();
  }

  Query<T> get _paginated {
    return query
      ..offset = (page - 1) * perPage
      ..limit = perPage;
  }
}

class Pagination<T> {
  late final List<T> data;
  late final int total;
  late final int currentPage;
  late final int perPage;
  late final int lastPage;
  late final int from;
  late final int to;

  Pagination({
    required this.data,
    required this.total,
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.from,
    required this.to,
  });
}
