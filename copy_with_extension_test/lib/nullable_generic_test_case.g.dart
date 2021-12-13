// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nullable_generic_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

class _NullableGenericTestCaseCopyWithProxy {
  final NullableGenericTestCase _value;

  _NullableGenericTestCaseCopyWithProxy(this._value);

  NullableGenericTestCase deepNestedGeneric(
          List<List<List<int?>?>>? deepNestedGeneric) =>
      deepNestedGeneric == null
          ? _value.copyWithNull(deepNestedGeneric: true)
          : _value.copyWith(deepNestedGeneric: deepNestedGeneric);

  NullableGenericTestCase nullableGeneric(List<String?> nullableGeneric) =>
      _value.copyWith(nullableGeneric: nullableGeneric);
}

extension NullableGenericTestCaseCopyWith on NullableGenericTestCase {
  _NullableGenericTestCaseCopyWithProxy get copyWithField =>
      _NullableGenericTestCaseCopyWithProxy(this);

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
