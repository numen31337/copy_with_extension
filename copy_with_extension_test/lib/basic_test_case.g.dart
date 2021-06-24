// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension BasicClassCopyWith on BasicClass {
  BasicClass copyWith({
    String? id,
    String? optional,
  }) {
    return BasicClass(
      id: id ?? this.id,
      optional: optional ?? this.optional,
    );
  }

  BasicClass copyWithNull({
    bool optional = false,
  }) {
    return BasicClass(
      id: id,
      optional: optional == true ? null : this.optional,
    );
  }
}

extension BasicClassOnlyNonNullableCopyWith on BasicClassOnlyNonNullable {
  BasicClassOnlyNonNullable copyWith({
    String? id,
    String? nextID,
  }) {
    return BasicClassOnlyNonNullable(
      id: id ?? this.id,
      nextID: nextID ?? this.nextID,
    );
  }
}
