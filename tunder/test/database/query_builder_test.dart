import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/exceptions/record_not_found_exception.dart';
import 'package:tunder/test.dart';

import '../examples/models.dart';

main() {
  group('Query<T>', () {
    useDatabaseTransactions();

    setUp(() async {
      await Schema.create('users', (table) {
        table.id();
        table.string('name').notNullable();
        table.string('email').nullable();
        table.boolean('admin').nullable();
        table.timestamps();
      });
      await Query('users').insert({
        'name': 'Marco',
        'email': 'marco@mail.com',
        'admin': true,
        'created_at': DateTime.parse('2022-05-27 05:04:23.805328Z'),
        'updated_at': DateTime.parse('2022-05-27 05:04:23.805328Z'),
      });
      await Query('users').insert({
        'name': 'John Doe',
        'email': 'john.doe@mail.com',
      });
    });

    test('can be initialized with table name: Query(tableName)', () async {
      var query = Query('users')..where('id').equals(1);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "id" = 1');
      var users = await query.get();
      expect(users.length, 1);
      expect(users.first, TypeMatcher<Map>());
    });

    test('can be initialized passing the type to constructor: Query(User)',
        () async {
      var query = Query(User)..where('id').equals(1);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "id" = 1');
      var users = await query.get();
      expect(users.length, 1);
      expect(users.first, TypeMatcher<Map>());
    });

    test('Query<User>().all() returns all users from the table', () async {
      List<User> users = await Query<User>().all();

      expect(users, isNotEmpty);

      final user = users.firstWhere((user) => user.id == 1);

      expect(user, isA<User>());
      expect(user.id, 1);
      expect(user.name, 'Marco');
      expect(user.email, 'marco@mail.com');
      expect(user.created_at, isNotNull);
      expect(user.updated_at, isNotNull);
    });

    // .find(id) should return the user with the given id
    // .findBy('email', email) should return the user with the given email
    test(
        ".add(Where('email').equals('some@mail.com')) should return the user with the given email",
        () async {
      var query = Query<User>().add(Where('email').equals('john.doe@mail.com'));
      String sql = query.toSql();
      expect(sql,
          'SELECT * FROM "users" WHERE "email" = \$\$john.doe@mail.com\$\$');
      List<User> users = await query.get();
      expect(users.length, 1);
      expect(users.first.name, 'John Doe');
      expect(users.first.email, 'john.doe@mail.com');
      expect(users.first.id, 2);
    });

    test('and() is an alias to add', () {
      var query = Query<User>().and(Where('email').equals('john.doe@mail.com'));

      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "email" = \$\$john.doe@mail.com\$\$');
    });

    test('or() adds an OR clause to the query', () async {
      var query = Query<User>()
          .add(Where('email').equals('john.doe@mail.com'))
          .or(Where('email').contains('john.doe'))
          .and(Where('email').endsWith('@mail.com'))
          .or(Where('email').startsWith('john'));

      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "email" = \$\$john.doe@mail.com\$\$ OR "email" LIKE \$\$%john.doe%\$\$ AND "email" LIKE \$\$%@mail.com\$\$ OR "email" LIKE \$\$john%\$\$');

      var users = await query.get();
      expect(users.length, 1);
    });

    test('can be chained with cascade notation', () async {
      var query = Query<User>()
        ..where('email').endsWith('@mail.com')
        ..where('email').startsWith('john.doe')
        ..orWhere('email').isNotNull;

      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "email" LIKE \$\$%@mail.com\$\$ AND "email" LIKE \$\$john.doe%\$\$ OR "email" IS NOT NULL');
      var users = await query.get();
      expect(users.length, 2);
    });

    test('starting with orWhere removes the first OR from the query', () async {
      var query = Query<User>()
        ..orWhere('email').startsWith('marco')
        ..orWhere('email').startsWith('john.doe')
        ..where('admin').isTrue;
      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "email" LIKE \$\$marco%\$\$ OR "email" LIKE \$\$john.doe%\$\$ AND "admin" IS TRUE');
      var users = await query.get();
      expect(users.length, 1);
    });

    test(
        'group where clauses with parenthesis with [and] and [or] getters api in Where objects',
        () async {
      var query = Query<User>()
        ..where('email').endsWith('@mail.com').and.startsWith('john.doe')
        ..where('name').equals('Marco')
        ..orWhere('email').isNotNull;

      expect(query.toSql(),
          'SELECT * FROM "users" WHERE ("email" LIKE \$\$%@mail.com\$\$ AND "email" LIKE \$\$john.doe%\$\$) AND "name" = \$\$Marco\$\$ OR "email" IS NOT NULL');
      var users = await query.get();
      expect(users.length, 2);
    });

    test('group where clauses and remove trailing parenthesis', () async {
      var query = Query<User>()
        ..where('email')
            .endsWith('@mail.com')
            .and
            .startsWith('john.doe')
            .or
            .contains('@mail')
        ..orWhere('admin').isNot(true);

      expect(query.toSql(),
          'SELECT * FROM "users" WHERE ("email" LIKE \$\$%@mail.com\$\$ AND "email" LIKE \$\$john.doe%\$\$ OR "email" LIKE \$\$%@mail%\$\$) OR "admin" IS NOT true');
      var users = await query.get();
      expect(users.length, 2);
    });

    test('Where.notEqual and Where.different', () async {
      var query = Query<User>()
        ..where('email').notEqual('marco@mail.com')
        ..orWhere('email').different('marco@mail.com');

      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "email" != \$\$marco@mail.com\$\$ OR "email" != \$\$marco@mail.com\$\$');
      var users = await query.get();
      expect(users.length, 1);
    });

    group('Nullable operators', () {
      test('Where.isNull', () async {
        var query = Query<User>()..where('email').isNull;
        expect(query.toSql(), 'SELECT * FROM "users" WHERE "email" IS NULL');
      });

      test('Where.equals(null) builds with IS NULL', () {
        var query = Query<User>()..where('email').equals(null);
        expect(query.toSql(), 'SELECT * FROM "users" WHERE "email" IS NULL');
      });

      test('Where.isNotNull', () {
        var query = Query<User>()..where('email').isNotNull;
        expect(
            query.toSql(), 'SELECT * FROM "users" WHERE "email" IS NOT NULL');
      });
    });

    test('Query.select(columns)', () async {
      var query = Query<User>().select(['id', 'name']);

      expect(query.toSql(), 'SELECT "users"."id", "users"."name" FROM "users"');
      var users = await query.all();
      expect(users.length, 2);
    });

    test('Where.contains(value) builds with LIKE %...%', () async {
      var query = Query<User>()..where('email').contains('marco');
      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "email" LIKE \$\$%marco%\$\$');
      var users = await query.get();
      expect(users.length, 1);
    });

    test(
        'Where.contains(value).caseInsensitive builds with ILIKE \$\$%...%\$\$',
        () async {
      var query = Query<User>()
        ..where('email').contains('marco').caseInsensitive;
      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "email" ILIKE \$\$%marco%\$\$');
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Where.contains(value).insensitive is an alias of caseInsensitive',
        () async {
      var query = Query<User>()..where('email').contains('marco').insensitive;
      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "email" ILIKE \$\$%marco%\$\$');
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Where.greaterThan(value) builds with >', () async {
      var query = Query<User>()..where('id').greaterThan(1);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "id" > 1');
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Where.greaterThanOrEqual(value) builds with >=', () async {
      var query = Query<User>()..where('id').greaterThanOrEqual(1);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "id" >= 1');
      var users = await query.get();
      expect(users.length, 2);
    });

    test('Where.lessThan(value) builds with <', () async {
      var query = Query<User>()..where('id').lessThan(1);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "id" < 1');
      var users = await query.get();
      expect(users.length, 0);
    });

    test('Where.lessThanOrEqual(value) builds with <=', () async {
      var query = Query<User>()..where('id').lessThanOrEqual(1);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "id" <= 1');
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Where.isIn(values) builds with IN', () async {
      var query = Query<User>()..where('id').isIn([1, 2, 3]);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "id" IN (1, 2, 3)');
      var users = await query.get();
      expect(users.length, 2);
    });

    test('Where.inList(values) is an alias of isIn', () async {
      var query = Query<User>()..where('id').inList([1, 2, 3]);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "id" IN (1, 2, 3)');
      var users = await query.get();
      expect(users.length, 2);
    });

    test('Where.isIn(string) builds with IN with strings', () async {
      var query = Query<User>()
        ..where('name').isIn(['Marco', 'jetete', 'gorilla']);
      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "name" IN (\$\$Marco\$\$, \$\$jetete\$\$, \$\$gorilla\$\$)');
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Where.notIn(values) builds with NOT IN', () async {
      var query = Query<User>()..where('id').notIn([2, 3]);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "id" NOT IN (2, 3)');
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Where.isNotIn(values) is an alias of notIn', () async {
      var query = Query<User>()..where('id').isNotIn([2, 3]);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "id" NOT IN (2, 3)');
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Where.notIn(string) builds with NOT IN with strings', () async {
      var query = Query<User>()
        ..where('name').notIn([
          'Marco',
          'John',
        ]);
      expect(
        query.toSql(),
        'SELECT * FROM "users" WHERE "name" NOT IN (\$\$Marco\$\$, \$\$John\$\$)',
      );
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Where.between(value, value) builds with BETWEEN', () async {
      var query = Query<User>()..where('id').between(1, 2);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "id" BETWEEN 1 AND 2');
      var users = await query.get();
      expect(users.length, 2);
    });

    test('Where.between(date1, date2) builds with BETWEEN', () async {
      var query = Query<User>()
        ..where('created_at').between(
          DateTime.parse('2022-05-27 05:04:22'),
          DateTime.parse('2022-05-27 05:04:24'),
        );
      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "created_at" BETWEEN \$\$2022-05-27 05:04:22.000\$\$ AND \$\$2022-05-27 05:04:24.000\$\$');
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Where.notBetween(date1, date2) builds with NOT BETWEEN', () async {
      var query = Query<User>()
        ..where('created_at').notBetween(
          DateTime.parse('2022-05-27 05:04:22'),
          DateTime.parse('2022-05-27 05:04:24'),
        );
      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "created_at" NOT BETWEEN \$\$2022-05-27 05:04:22.000\$\$ AND \$\$2022-05-27 05:04:24.000\$\$');
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Where.isTrue builds with IS TRUE', () async {
      var query = Query<User>()..where('admin').isTrue;
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "admin" IS TRUE');
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Where.isFalse builds with IS FALSE', () async {
      var query = Query<User>()..where('admin').isFalse;
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "admin" IS FALSE');
      var users = await query.get();
      expect(users.length, 0);
    });

    test('Where.isNot(value) builds with IS NOT', () async {
      var query = Query<User>()..where('admin').isNot(true);
      expect(query.toSql(), 'SELECT * FROM "users" WHERE "admin" IS NOT true');
      var users = await query.get();
      expect(users.length, 1);
    });

    test('Query.orderBy(column, direction) builds with ORDER BY', () async {
      var query = Query<User>().orderBy('id').paginate();
      expect(query.toSql(),
          'SELECT * FROM "users" ORDER BY "id" ASC OFFSET 0 LIMIT 10');
      var pagination = await query.get();
      expect(pagination.total, 2);
    });

    test('Query.findBy(column, value) builds and returns the value', () async {
      User user = await Query<User>().findBy('id', 1);
      expect(user.id, 1);
    });

    test('Query.find(value) builds with defaults to ID', () async {
      User user = await Query<User>().find(1);
      expect(user.id, 1);
    });

    test('Query.find(value) throws an error if doesnt find the record',
        () async {
      expect(
        () => Query<User>().find(321),
        throwsA(isA<RecordNotFoundException>()),
      );
    });

    test('Query.findOrNull(value) returns null if doesnt find the record',
        () async {
      User? user = await Query<User>().findOrNull(321);
      expect(user, isNull);
      expect(await Query<User>().findOrNull(1), isNotNull);
    });

    test('Query.whereMap(map) builds where clause with equal values', () async {
      var query = Query<User>().whereMap({'id': 1, 'name': 'Marco'});
      expect(query.toSql(),
          'SELECT * FROM "users" WHERE "id" = 1 AND "name" = \$\$Marco\$\$');
      var users = await query.get();
      expect(users.length, 1);
    });
  });
}
