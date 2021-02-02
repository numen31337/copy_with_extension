// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'implements_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension BasicCopyWith on Basic {
  Basic copyWith({
    String? aField,
  }) {
    return Basic(
      aField: aField ?? this.aField,
    );
  }
}

extension WithGenericTypeCopyWith<T> on WithGenericType<T> {
  WithGenericType<T> copyWith({
    T? tField,
  }) {
    return WithGenericType<T>(
      tField: tField ?? this.tField,
    );
  }
}

extension WithSpecificTypeCopyWith on WithSpecificType {
  WithSpecificType copyWith({
    String? tField,
  }) {
    return WithSpecificType(
      tField: tField ?? this.tField,
    );
  }
}

extension WithBothCopyWith<T extends String, Y> on WithBoth<T, Y> {
  WithBoth<T, Y> copyWith({
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
