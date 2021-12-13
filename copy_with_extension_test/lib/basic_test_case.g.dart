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

extension BasicClassNamedCopyWith on BasicClassNamed {
  BasicClassNamed copyWith({
    String? id,
    String? optional,
  }) {
    return BasicClassNamed._(
      id: id ?? this.id,
      optional: optional ?? this.optional,
    );
  }
}

extension BasicClassNamed1CopyWith on BasicClassNamed1 {
  BasicClassNamed1 copyWith({
    String? id,
    String? optional,
  }) {
    return BasicClassNamed1.test(
      id: id ?? this.id,
      optional: optional ?? this.optional,
    );
  }

  BasicClassNamed1 copyWithNull({
    bool optional = false,
  }) {
    return BasicClassNamed1.test(
      id: id,
      optional: optional == true ? null : this.optional,
    );
  }
}
