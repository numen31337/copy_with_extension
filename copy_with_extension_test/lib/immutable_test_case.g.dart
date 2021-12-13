// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'immutable_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

class _TestCaseClassCopyWithProxy<T extends String> {
  final TestCaseClass _value;

  _TestCaseClassCopyWithProxy(this._value);

  TestCaseClass id(T id) => _value.copyWith(id: id);
}

extension TestCaseClassCopyWith<T extends String> on TestCaseClass<T> {
  _TestCaseClassCopyWithProxy get copyWithField =>
      _TestCaseClassCopyWithProxy<T>(this);

  TestCaseClass<T> copyWith({
    T? id,
  }) {
    return TestCaseClass<T>(
      id: id ?? this.id,
      immutableField: immutableField,
    );
  }
}
