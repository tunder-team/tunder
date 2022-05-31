import 'package:test/test.dart';
import 'package:tunder/database.dart';

main() {
  group('Model class', () {
    group('fill() method', () {
      test('should fill from map', () {
        User user = User();

        user.fill({'name': 'Marco'});

        expect(user.name, 'Marco');
      });

      test('it tries to cast the value to the type of the property', () {
        User user = User();

        user.fill({'id': '1'});

        expect(user.id, 1);
      });

      test('full example', () {
        User user = User();

        user.fill({
          'id': '1',
          'name': 'Marco',
          'email': 'marco@mail.com',
          'createdAt': '2022-05-27 05:04:23.805328',
          'updatedAt': '2022-05-27 05:04:23.805328',
        });

        expect(user.id, 1);
        expect(user.name, 'Marco');
        expect(user.email, 'marco@mail.com');
        expect(user.createdAt, DateTime.parse('2022-05-27 05:04:23.805328'));
        expect(user.updatedAt, DateTime.parse('2022-05-27 05:04:23.805328'));
      });
    });
  });
}

class User extends Model<User> {
  int? id;
  String? name;
  String? email;
  late DateTime createdAt;
  late DateTime updatedAt;
}
