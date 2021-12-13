import 'package:test/test.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

void main() {
  test('annotation exists', () {
    const annotation = CopyWith();
    expect(annotation.generateCopyWithNull, false);
  });
}
