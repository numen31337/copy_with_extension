// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

class _BasicClassCopyWithProxy {
  final BasicClass _value;

  _BasicClassCopyWithProxy(this._value);

  BasicClass optional(String? optional) => optional == null
      ? _value.copyWithNull(optional: true)
      : _value.copyWith(optional: optional);

  BasicClass id(String id) => _value.copyWith(id: id);
}

extension BasicClassCopyWith on BasicClass {
  _BasicClassCopyWithProxy get copyWithField => _BasicClassCopyWithProxy(this);

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

class _BasicClassOnlyNonNullableCopyWithProxy {
  final BasicClassOnlyNonNullable _value;

  _BasicClassOnlyNonNullableCopyWithProxy(this._value);

  BasicClassOnlyNonNullable id(String id) => _value.copyWith(id: id);

  BasicClassOnlyNonNullable nextID(String nextID) =>
      _value.copyWith(nextID: nextID);
}

extension BasicClassOnlyNonNullableCopyWith on BasicClassOnlyNonNullable {
  _BasicClassOnlyNonNullableCopyWithProxy get copyWithField =>
      _BasicClassOnlyNonNullableCopyWithProxy(this);

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

class _BasicClassNamed1CopyWithProxy {
  final BasicClassNamed1 _value;

  _BasicClassNamed1CopyWithProxy(this._value);

  BasicClassNamed1 optional(String? optional) => optional == null
      ? _value.copyWithNull(optional: true)
      : _value.copyWith(optional: optional);

  BasicClassNamed1 id(String id) => _value.copyWith(id: id);
}

extension BasicClassNamed1CopyWith on BasicClassNamed1 {
  _BasicClassNamed1CopyWithProxy get copyWithField =>
      _BasicClassNamed1CopyWithProxy(this);

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
