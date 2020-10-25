// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'immutable_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension TestCaseClassCopyWithExtension<T extends String> on TestCaseClass<T> {
  TestCaseClass<T> copyWith({
    T id,
  }) {
    return TestCaseClass<T>(
      id: id ?? this.id,
      immutableField: immutableField,
    );
  }

  TestCaseClass<T> copyWithNull({
    bool id = false,
  }) {
    return TestCaseClass<T>(
      id: id == true ? null : this.id,
      immutableField: immutableField,
    );
  }
}
