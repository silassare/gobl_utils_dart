import 'package:gobl_utils_dart/gobl_utils_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Gobl class tests', () {
    Gobl gobl;

    setUp(() {
      gobl = Gobl();
    });

    test('Gobl is a Singleton', () {
      expect(identical(gobl, Gobl()), isTrue);
    });
  });
}
