// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'implements_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

class _BasicCopyWithProxy {
  final Basic _value;

  _BasicCopyWithProxy(this._value);

  Basic aField(String aField) => _value._copyWithValues(aField: aField);
}

extension BasicCopyWith on Basic {
  _BasicCopyWithProxy get copyWith => _BasicCopyWithProxy(this);

  Basic _copyWithValues({
    String? aField,
  }) {
    return Basic(
      aField: aField ?? this.aField,
    );
  }
}

class _WithGenericTypeCopyWithProxy<T> {
  final WithGenericType _value;

  _WithGenericTypeCopyWithProxy(this._value);

  WithGenericType tField(T tField) => _value._copyWithValues(tField: tField);
}

extension WithGenericTypeCopyWith<T> on WithGenericType<T> {
  _WithGenericTypeCopyWithProxy get copyWith =>
      _WithGenericTypeCopyWithProxy<T>(this);

  WithGenericType<T> _copyWithValues({
    T? tField,
  }) {
    return WithGenericType<T>(
      tField: tField ?? this.tField,
    );
  }
}

class _WithSpecificTypeCopyWithProxy {
  final WithSpecificType _value;

  _WithSpecificTypeCopyWithProxy(this._value);

  WithSpecificType tField(String tField) =>
      _value._copyWithValues(tField: tField);
}

extension WithSpecificTypeCopyWith on WithSpecificType {
  _WithSpecificTypeCopyWithProxy get copyWith =>
      _WithSpecificTypeCopyWithProxy(this);

  WithSpecificType _copyWithValues({
    String? tField,
  }) {
    return WithSpecificType(
      tField: tField ?? this.tField,
    );
  }
}

class _WithBothCopyWithProxy<T extends String, Y> {
  final WithBoth _value;

  _WithBothCopyWithProxy(this._value);

  WithBoth aField(String aField) => _value._copyWithValues(aField: aField);

  WithBoth sa1Field(Y sa1Field) => _value._copyWithValues(sa1Field: sa1Field);

  WithBoth saField(String saField) => _value._copyWithValues(saField: saField);

  WithBoth t1Field(int t1Field) => _value._copyWithValues(t1Field: t1Field);

  WithBoth tField(T tField) => _value._copyWithValues(tField: tField);
}

extension WithBothCopyWith<T extends String, Y> on WithBoth<T, Y> {
  _WithBothCopyWithProxy get copyWith => _WithBothCopyWithProxy<T, Y>(this);

  WithBoth<T, Y> _copyWithValues({
    String? aField,
    Y? sa1Field,
    String? saField,
    int? t1Field,
    T? tField,
  }) {
    return WithBoth<T, Y>(
      aField: aField ?? this.aField,
      sa1Field: sa1Field ?? this.sa1Field,
      saField: saField ?? this.saField,
      t1Field: t1Field ?? this.t1Field,
      tField: tField ?? this.tField,
    );
  }
}
