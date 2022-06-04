import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/providers/database_service_provider.dart';
import 'package:tunder/utils.dart';

import '../examples/models.dart';

main() {
  group('Query.paginate', () {
    setUpAll(() async {
      DatabaseServiceProvider().boot(app());
      List data =
          json.decode(File('test/fixtures/posts.json').readAsStringSync());

      // Create table in Postgres
      var createTable = '''
        CREATE TABLE IF NOT EXISTS posts (
          id BIGSERIAL PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          body TEXT NOT NULL,
          created_at TIMESTAMP NOT NULL DEFAULT NOW(),
          updated_at TIMESTAMP NOT NULL DEFAULT NOW()
        );
      ''';
      await DB.execute(createTable);

      // Insert Posts
      for (var post in data) {
        var insert = '''
          INSERT INTO posts (id, title, body, created_at, updated_at)
          VALUES (${post['id']}, '${post['title']}', '${post['body']}', '${post['created_at']}', '${post['updated_at']}');
        ''';
        await DB.execute(insert);
      }
    });

    tearDownAll(() async {
      await DB.execute('DROP TABLE IF EXISTS posts');
    });

    test('it paginates per 10 by default', () async {
      final query = Query<Post>();
      Paginator<Post> paginator = query.paginate();
      expect(paginator.perPage, 10);
      expect(paginator.page, 1);
      Pagination<Post> result = await paginator.get();

      expect(paginator.toSql(), 'SELECT * FROM "posts" OFFSET 0 LIMIT 10');
      expect(result.data, TypeMatcher<List<Post>>());
      expect(result.data.length, 10);
      expect(result.total, 12);
      expect(result.lastPage, 2);
      expect(result.from, 1);
      expect(result.to, 10);
      expect(result.currentPage, 1);
      expect(result.perPage, 10);
    });

    test('page 2 with per page 10 should work', () async {
      final query = Query<Post>();
      Paginator<Post> paginator = query.paginate(page: 2);
      expect(paginator.perPage, 10);
      expect(paginator.page, 2);
      Pagination<Post> result = await paginator.get();

      expect(paginator.toSql(), 'SELECT * FROM "posts" OFFSET 10 LIMIT 10');
      expect(result.data, TypeMatcher<List<Post>>());
      expect(result.data.length, 2);
      expect(result.total, 12);
      expect(result.currentPage, 2);
      expect(result.lastPage, 2);
      expect(result.from, 11);
      expect(result.to, 12);
      expect(result.perPage, 10);
    });

    test('changing per page with 3', () async {
      final query = Query<Post>();
      Paginator<Post> paginator = query.paginate(page: 2, perPage: 3);
      expect(paginator.perPage, 3);
      expect(paginator.page, 2);
      Pagination<Post> result = await paginator.get();

      expect(paginator.toSql(), 'SELECT * FROM "posts" OFFSET 3 LIMIT 3');
      expect(result.data, TypeMatcher<List<Post>>());
      expect(result.data.length, 3);
      expect(result.total, 12);
      expect(result.perPage, 3);
      expect(result.currentPage, 2);
      expect(result.lastPage, 4);
      expect(result.from, 4);
      expect(result.to, 6);
    });
  });
}
