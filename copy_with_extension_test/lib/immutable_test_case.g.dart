// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'immutable_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

class _TestCaseClassCopyWithProxy<T extends String> {
  final TestCaseClass _value;

  _TestCaseClassCopyWithProxy(this._value);

  TestCaseClass id(T id) => _value._copyWithValues(id: id);
}

extension TestCaseClassCopyWith<T extends String> on TestCaseClass<T> {
  _TestCaseClassCopyWithProxy get copyWith =>
      _TestCaseClassCopyWithProxy<T>(this);

  TestCaseClass<T> _copyWithValues({
    T? id,
  }) {
    return TestCaseClass<T>(
      id: id ?? this.id,
      immutableField: immutableField,
    );
  }
}
