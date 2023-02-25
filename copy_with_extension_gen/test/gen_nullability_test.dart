import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart' show test, expect;

part 'gen_nullability_test.g.dart';

@CopyWith()
class TestNullability {
  TestNullability(
    int this.nullableWithNonNullableConstructor,
    this.dynamicField,
    this.integers,
  );

  /// https://github.com/numen31337/copy_with_extension/pull/69
  /// If a field is nullable, you can change the type of the constructor parameter to be non-nullable.
  final int? nullableWithNonNullableConstructor;

  /// https://github.com/numen31337/copy_with_extension/issues/74
  /// Test for crash on `instance.dynamicField!`.
  final dynamic dynamicField;

  /// https://github.com/numen31337/copy_with_extension/issues/75
  /// Warnings during compilation when using `!` on non-nullable value.
  /// Use `dart compile exe test/gen_nullability_test.dart && rm -fr test/gen_nullability_test.exe ` to reproduce the warning.
  final List<int> integers;
}

void main() {
  test('TestNullability', () {
    // Test for crash in both flows for `dynamicField`, when `dynamicField` is affected and not affected.
    expect(TestNullability(1, 1, [1]).copyWith.integers([2]).dynamicField, 1);
    expect(TestNullability(1, 1, [1]).copyWith.dynamicField(2).dynamicField, 2);
    expect(
      TestNullability(1, 1, [1]).copyWith(dynamicField: 2).dynamicField,
      2,
    );
    expect(
      TestNullability(1, 1, [1])
          .copyWith(nullableWithNonNullableConstructor: 1)
          .dynamicField,
      1,
    );
  });
}
