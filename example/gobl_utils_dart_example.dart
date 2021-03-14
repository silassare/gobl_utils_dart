import 'package:gobl_utils_dart/gobl_utils_dart.dart';

abstract class UserBase extends GoblEntity with GoblSinglePKEntity {
  UserBase(
      {Map<String, dynamic> initialData = const {},
      String name,
      String prefix,
      List<String> columns})
      : super(
            initialData: initialData,
            name: name,
            prefix: prefix,
            columns: columns);
}

class User extends UserBase {
  static const ENTITY_NAME = 'User';
  static const PREFIX = 'product';
  static const COLUMNS = [COL_ID, COL_NAME];

  static const COL_ID = 'user_id';
  static const COL_NAME = 'user_name';

  User(Map<String, dynamic> data)
      : super(
            name: ENTITY_NAME,
            prefix: PREFIX,
            columns: COLUMNS,
            initialData: data);

  @override
  User fromJson(Map<String, dynamic> json) {
    return User(json);
  }

  @override
  List<String> identifierColumns() {
    return [COL_ID];
  }

  @override
  String singlePKValue() {
    return [id].join();
  }

  num get id {
    return doGet(COL_ID, num);
  }

  set id(num v) {
    return doSet(COL_ID, v, num);
  }

  String get name {
    return doGet(COL_NAME, String);
  }

  set name(String v) {
    return doSet(COL_NAME, v, String);
  }
}

void main() {
  var gobl = Gobl();

  gobl.register(name: User.ENTITY_NAME, entity: User, columns: User.COLUMNS);

  var json = '{"error": 0, user: {"user_id": "1", "user_name": "John Doe"}}';

  var data = gobl.parse(json);

  print(data.user.name);
}
