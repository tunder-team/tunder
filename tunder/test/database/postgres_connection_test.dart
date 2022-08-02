// import 'package:test/test.dart';
// import 'package:tunder/database.dart';
// import 'package:tunder/src/providers/database_service_provider.dart';
// import 'package:tunder/test.dart';
// import 'package:tunder/utils.dart';

main() {
//   useDatabaseTransactions();

//   group('PostgresConnection', () {
//     late DatabaseConnection connection;
//     String testingTable = 'sample_table_postgres_connection';

//     setUpAll(() async {
//       DatabaseServiceProvider().boot(app());
//       connection = DB.connection;
//       await Schema.create('$testingTable', (table) {
//         table.id();
//         table.string('name').notNullable();
//       });
//       await DB.execute("insert into $testingTable (name) values ('Marco')");
//       await DB.execute("insert into $testingTable (name) values ('John Doe')");
//     });

//     tearDownAll(() async {
//       await Schema.drop('$testingTable');
//     });

//     test('open() connection', () async {
//       await connection.open();
//     });

//     test('query(sql) executes a query and return as map', () async {
//       var rows = await connection.query(
//         'SELECT * FROM $testingTable',
//       );
//       expect(rows, isNotEmpty);
//       expect(rows.length, 2);
//       expect(rows.first, TypeMatcher<Map>());
//       expect(rows.first['id'], TypeMatcher<int>());
//     });

//     test('execute(sql) returns the number of affected rows', () async {
//       var affectedRows = await connection.execute(
//         "UPDATE $testingTable SET name = 'John' WHERE id = 1",
//       );
//       expect(affectedRows, 1);
//       affectedRows = await connection.execute(
//         "UPDATE $testingTable SET name = 'Marco' WHERE id = 1",
//       );
//       expect(affectedRows, 1);
//     });

//     test('transaction(function) executes a function in a transaction',
//         () async {
//       var queryJose = "SELECT * FROM $testingTable WHERE name = 'Jose'";

//       try {
//         await connection.transaction(() async {
//           var insertJose = "INSERT INTO $testingTable (name) VALUES ('Jose')";
//           var insertAnna = "INSERT INTO $testingTable (name) VALUES ('Anna')";
//           var affectedRows = await connection.execute(insertJose);
//           expect(affectedRows, 1);
//           affectedRows = await connection.execute(insertAnna);
//           expect(affectedRows, 1);
//           var results = await connection.query(queryJose);
//           expect(results, isNotEmpty);

//           results = await connection.query('SELECT * FROM $testingTable');
//           expect(results.length, 4);

//           throw SomeException('Some error');
//         });
//       } on SomeException catch (e) {
//         expect(e.message, 'Some error');
//       }

//       var results = await connection.query(queryJose);
//       expect(results, isEmpty);
//     });

//     test('begin() and rollback()', () async {
//       // Arrange
//       var insertRobert = "INSERT INTO $testingTable (name) VALUES ('Robert')";

//       // Act
//       await connection.begin();
//       var result = await connection.execute(insertRobert);
//       expect(result, 1);
//       await connection.rollback();

//       // Assert
//       expect(
//           await DB.connection
//               .query("SELECT * from $testingTable where name = 'Robert'"),
//           isEmpty);
//     });

//     test('begin() and commit() should persist in database', () async {
//       // Arrange
//       var insertRobert = "INSERT INTO $testingTable (name) VALUES ('Robert')";
//       var deleteRobert = "DELETE FROM $testingTable WHERE name = 'Robert'";

//       // Act
//       await connection.begin();
//       var result = await connection.execute(insertRobert);
//       expect(result, 1);
//       await connection.commit();

//       // Assert
//       expect(
//           await DB.connection
//               .query("SELECT * from $testingTable where name = 'Robert'"),
//           isNotEmpty);

//       // Cleanup
//       await connection.execute(deleteRobert);
//       expect(
//           await DB.connection
//               .query("SELECT * from $testingTable where name = 'Robert'"),
//           isEmpty);
//     });

//     test(
//         'transaction(operation) should run a transaction and commit at the end',
//         () async {
//       // Arrange
//       var insertRobert = "INSERT INTO $testingTable (name) VALUES ('Robert')";
//       var deleteRobert = "DELETE FROM $testingTable WHERE name = 'Robert'";

//       // Act
//       var result =
//           await connection.transaction(() => connection.execute(insertRobert));
//       expect(result, 1);

//       // Assert
//       expect(
//           await DB.connection
//               .query("SELECT * from $testingTable where name = 'Robert'"),
//           isNotEmpty);

//       // Cleanup
//       await connection.execute(deleteRobert);
//       expect(
//           await DB.connection
//               .query("SELECT * from $testingTable where name = 'Robert'"),
//           isEmpty);
//     });

//     test('close connection', () {
//       connection.close();
//     });
//   });
}

// class SomeException implements Exception {
//   final String message;

//   SomeException(this.message);
// }
