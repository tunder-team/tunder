import 'package:test/test.dart';
import 'package:tunder/extensions.dart';

main() {
  group('Unique on List:', () {
    test('[1, 2, 3, 3, 2].unique() returns [1, 2, 3]', () {
      expect([1, 2, 3, 3, 2].unique(), [1, 2, 3]);
    });

    test('["a", "b", "c", "a", "b"].unique() returns ["a", "b", "c"]', () {
      expect(["a", "b", "c", "a", "b"].unique(), ["a", "b", "c"]);
    });

    test('.unique(callback, inplace: false) dont mutate the list', () {
      var user1 = User(1);
      var user2 = User(2);
      var list = [user1, user2, User(1)];
      expect(list.unique(by: (u) => u.id), [user1, user2]);
      expect(list, [user1, user2]);

      var list2 = [user1, user2, user1];
      expect(list2.unique(by: (u) => u.id, inplace: false), [user1, user2]);
      expect(list2, [user1, user2, user1]);
    });
  });
}

class User {
  int id;

  User(this.id);
}
