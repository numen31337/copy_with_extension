// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

class _BasicClassCopyWithProxy {
  final BasicClass _value;

  _BasicClassCopyWithProxy(this._value);

  BasicClass optional(String? optional) => optional == null
      ? _value._copyWithNull(optional: true)
      : _value._copyWithValues(optional: optional);

  BasicClass id(String id) => _value._copyWithValues(id: id);
}

extension BasicClassCopyWith on BasicClass {
  _BasicClassCopyWithProxy get copyWith => _BasicClassCopyWithProxy(this);

  BasicClass _copyWithValues({
    String? id,
    String? optional,
  }) {
    return BasicClass(
      id: id ?? this.id,
      optional: optional ?? this.optional,
    );
  }

  BasicClass _copyWithNull({
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

  BasicClassOnlyNonNullable id(String id) => _value._copyWithValues(id: id);

  BasicClassOnlyNonNullable nextID(String nextID) =>
      _value._copyWithValues(nextID: nextID);
}

extension BasicClassOnlyNonNullableCopyWith on BasicClassOnlyNonNullable {
  _BasicClassOnlyNonNullableCopyWithProxy get copyWith =>
      _BasicClassOnlyNonNullableCopyWithProxy(this);

  BasicClassOnlyNonNullable _copyWithValues({
    String? id,
    String? nextID,
  }) {
    return BasicClassOnlyNonNullable(
      id: id ?? this.id,
      nextID: nextID ?? this.nextID,
    );
  }
}

class _BasicClassNamedCopyWithProxy {
  final BasicClassNamed _value;

  _BasicClassNamedCopyWithProxy(this._value);

  BasicClassNamed optional(String? optional) => optional == null
      ? _value._copyWithNull(optional: true)
      : _value.copyWithValues(optional: optional);

  BasicClassNamed id(String id) => _value.copyWithValues(id: id);
}

extension BasicClassNamedCopyWith on BasicClassNamed {
  _BasicClassNamedCopyWithProxy get copyWith =>
      _BasicClassNamedCopyWithProxy(this);

  BasicClassNamed copyWithValues({
    String? id,
    String? optional,
  }) {
    return BasicClassNamed._(
      id: id ?? this.id,
      optional: optional ?? this.optional,
    );
  }

  BasicClassNamed _copyWithNull({
    bool optional = false,
  }) {
    return BasicClassNamed._(
      id: id,
      optional: optional == true ? null : this.optional,
    );
  }
}

class _BasicClassNamedWithoutCopyWithAndCopyWithNullCopyWithProxy {
  final BasicClassNamedWithoutCopyWithAndCopyWithNull _value;

  _BasicClassNamedWithoutCopyWithAndCopyWithNullCopyWithProxy(this._value);

  BasicClassNamedWithoutCopyWithAndCopyWithNull optional(String? optional) =>
      optional == null
          ? _value._copyWithNull(optional: true)
          : _value._copyWithValues(optional: optional);

  BasicClassNamedWithoutCopyWithAndCopyWithNull id(String id) =>
      _value._copyWithValues(id: id);
}

extension BasicClassNamedWithoutCopyWithAndCopyWithNullCopyWith
    on BasicClassNamedWithoutCopyWithAndCopyWithNull {
  _BasicClassNamedWithoutCopyWithAndCopyWithNullCopyWithProxy get copyWith =>
      _BasicClassNamedWithoutCopyWithAndCopyWithNullCopyWithProxy(this);

  BasicClassNamedWithoutCopyWithAndCopyWithNull _copyWithValues({
    String? id,
    String? optional,
  }) {
    return BasicClassNamedWithoutCopyWithAndCopyWithNull.test(
      id: id ?? this.id,
      optional: optional ?? this.optional,
    );
  }

  BasicClassNamedWithoutCopyWithAndCopyWithNull _copyWithNull({
    bool optional = false,
  }) {
    return BasicClassNamedWithoutCopyWithAndCopyWithNull.test(
      id: id,
      optional: optional == true ? null : this.optional,
    );
  }
}
