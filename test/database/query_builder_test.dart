import 'package:postgres/postgres.dart';
import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/tunder.dart';
import 'package:tunder/utils.dart';

main() {
  group('Query<T>', () {
    setUpAll(() {
      (app() as Application).bind(
        DatabaseConnection,
        (_) => PostgreSQLConnection(
          "localhost",
          5432,
          "tunder_test",
          username: "postgres",
          password: "docker",
        ),
      );
    });

    test('Query<User>().all() returns all users from the table', () async {
      List<User> users = await Query<User>().all();

      expect(users, isNotEmpty);

      final user = users.first;

      expect(user, isA<User>());
      expect(user.id, 1);
      expect(user.name, 'Marco');
      expect(user.email, 'marco@mail.com');
      expect(user.created_at, DateTime.parse('2022-05-27 05:04:23.805328Z'));
      expect(user.updated_at, DateTime.parse('2022-05-27 05:04:23.805328Z'));
    });

    // .find(id) should return the user with the given id
    // .findBy('email', email) should return the user with the given email
    test(
        ".add(Where('email').equals('some@mail.com')) should return the user with the given email",
        () async {
      var query = Query<User>().add(Where('email').equals('john.doe@mail.com'));
      String sql = query.toSql();
      expect(sql, "SELECT * FROM users WHERE email = 'john.doe@mail.com'");
      List<User> users = await query.get();
      expect(users.length, 1);
      expect(users.first.name, 'John Doe');
      expect(users.first.email, 'john.doe@mail.com');
      expect(users.first.id, 2);
    });

    test('and() is an alias to add', () {
      var query = Query<User>().and(Where('email').equals('john.doe@mail.com'));

      expect(query.toSql(),
          "SELECT * FROM users WHERE email = 'john.doe@mail.com'");
    });

    test('or() adds an OR clause to the query', () async {
      var query = Query<User>()
          .add(Where('email').equals('john.doe@mail.com'))
          .or(Where('email').contains('john.doe'))
          .and(Where('email').endsWith('@mail.com'))
          .or(Where('email').startsWith('john'));

      expect(query.toSql(),
          "SELECT * FROM users WHERE email = 'john.doe@mail.com' OR email LIKE '%john.doe%' AND email LIKE '%@mail.com' OR email LIKE 'john%'");

      var users = await query.get();
      expect(users.length, 1);
    });

    test('can be chained with cascade notation', () async {
      var query = Query<User>()
        ..where('email').endsWith('@mail.com')
        ..where('email').startsWith('john.doe')
        ..orWhere('email').isNotNull;

      expect(query.toSql(),
          "SELECT * FROM users WHERE email LIKE '%@mail.com' AND email LIKE 'john.doe%' OR email IS NOT NULL");
      var users = await query.get();
      expect(users.length, 2);
    });

    test('Where.notEqual and Where.different', () async {
      var query = Query<User>()
        ..where('email').notEqual('marco@mail.com')
        ..orWhere('email').different('marco@mail.com');

      expect(query.toSql(),
          "SELECT * FROM users WHERE email != 'marco@mail.com' OR email != 'marco@mail.com'");
      var users = await query.get();
      expect(users.length, 1);
    });
  });
}

class User extends Model<User> {
  int? id;
  String? name;
  String? email;

  late DateTime created_at;
  late DateTime updated_at;
}
