import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/contracts/database_operator.dart';

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

  String toSql() => DatabaseOperator.forDriver(DB.driver).toSql(_paginated);

  Query<T> get _paginated => query
    ..offset = (page - 1) * perPage
    ..limit = perPage;
}

class Pagination<T> {
  final List<T> data;
  final int total;
  final int currentPage;
  final int perPage;
  final int lastPage;
  final int from;
  final int to;

  const Pagination({
    required this.data,
    required this.total,
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.from,
    required this.to,
  });
}
