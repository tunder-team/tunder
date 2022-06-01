import 'package:tunder/database.dart';

class User extends Model<User> {
  int? id;
  String? name;
  String? email;
  late DateTime created_at;
  late DateTime updated_at;
}
