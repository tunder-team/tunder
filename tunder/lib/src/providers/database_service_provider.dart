import 'package:tunder/database.dart';
import 'package:tunder/src/database/postgres_connection.dart';
import 'package:tunder/tunder.dart';
import 'package:tunder/utils.dart';

class DatabaseServiceProvider extends ServiceProvider {
  boot(Application app) {
    app.bind(
      DatabaseConnection,
      (_) => PostgresConnection(
        host: env('DB_HOST') ?? "localhost",
        port: int.parse(env('DB_PORT') ?? '5432'),
        database: env('DB_DATABASE') ?? "tunder_test",
        username: env('DB_USERNAME') ?? "postgres",
        password: env('DB_PASSWORD') ?? "docker",
      ),
    );
  }
}
