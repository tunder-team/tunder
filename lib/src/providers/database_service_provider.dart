import 'package:postgres/postgres.dart';
import 'package:tunder/database.dart';
import 'package:tunder/tunder.dart';
import 'package:tunder/utils.dart';

class DatabaseServiceProvider extends ServiceProvider {
  boot(Application app) {
    app.bind(
      DatabaseConnection,
      (_) => PostgreSQLConnection(
        env('DB_HOST') ?? "localhost",
        int.parse(env('DB_PORT') ?? '5432'),
        env('DB_DATABASE') ?? "tunder_test",
        username: env('DB_USERNAME') ?? "postgres",
        password: env('DB_PASSWORD') ?? "docker",
      ),
    );
  }
}
