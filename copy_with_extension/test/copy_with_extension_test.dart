import 'package:test/test.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

void main() {
  test('annotation exists', () {
    final annotation = const CopyWith();
    expect(annotation is CopyWith, true);
  });
}
