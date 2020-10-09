// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_case_class.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension Test_Case_ClassCopyWithExtension<T extends String>
    on Test_Case_Class<T> {
  Test_Case_Class<T> copyWith({
    T id,
  }) {
    return Test_Case_Class<T>(
      id: id ?? this.id,
      immutableField: immutableField,
    );
  }

  Test_Case_Class<T> copyWithNull({
    bool id = false,
  }) {
    return Test_Case_Class<T>(
      id: id == true ? null : this.id,
      immutableField: immutableField,
    );
  }
}
