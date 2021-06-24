// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nullable_generic_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension NullableGenericTestCaseCopyWith on NullableGenericTestCase {
  NullableGenericTestCase copyWith({
    List<List<List<int?>?>>? deepNestedGeneric,
    List<String?>? nullableGeneric,
  }) {
    return NullableGenericTestCase(
      deepNestedGeneric: deepNestedGeneric ?? this.deepNestedGeneric,
      nullableGeneric: nullableGeneric ?? this.nullableGeneric,
    );
  }

  NullableGenericTestCase copyWithNull({
    bool deepNestedGeneric = false,
  }) {
    return NullableGenericTestCase(
      deepNestedGeneric:
          deepNestedGeneric == true ? null : this.deepNestedGeneric,
      nullableGeneric: nullableGeneric,
    );
  }
}
