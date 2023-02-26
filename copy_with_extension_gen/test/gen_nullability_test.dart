import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart' show test, expect;

part 'gen_nullability_test.g.dart';

@CopyWith()
class TestNullability {
  TestNullability(
    this.dynamicField,
    this.integers,
  );

  /// https://github.com/numen31337/copy_with_extension/issues/74
  /// Test for crash on `instance.dynamicField!`.
  final dynamic dynamicField;

  /// https://github.com/numen31337/copy_with_extension/issues/75
  /// Warnings during compilation when using `!` on non-nullable value.
  /// Use `dart run copy_with_extension_gen/test/gen_nullability_test.dart` to reproduce the warning.
  final List<int> integers;
}

void main() {
  test('TestNullability', () {
    // Test for crash in both flows for `dynamicField`, when `dynamicField` is affected and not affected.
    expect(TestNullability(1, [1]).copyWith.integers([2]).dynamicField, 1);
    expect(TestNullability(1, [1]).copyWith.dynamicField(2).dynamicField, 2);
    expect(TestNullability(1, [1]).copyWith(dynamicField: 2).dynamicField, 2);
    expect(TestNullability(1, [1]).copyWith(integers: [1]).dynamicField, 1);
    expect(TestNullability(null, [1]).copyWith.dynamicField(1).dynamicField, 1);
    expect(
        TestNullability(null, [1]).copyWith.integers([2]).dynamicField, null);
  });
}
