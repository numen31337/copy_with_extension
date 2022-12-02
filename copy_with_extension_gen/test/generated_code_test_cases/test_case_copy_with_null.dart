part of 'source_gen_entrypoint.dart';

@ShouldGenerate(r'''
// ignore_for_file: unnecessary_non_null_assertion, duplicate_ignore

abstract class _$_PrivateWithNullableWithoutFieldsCWProxy<
    T extends Iterable<int>> {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// _PrivateWithNullableWithoutFields<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  _PrivateWithNullableWithoutFields<T> call({
    T? nullable,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOf_PrivateWithNullableWithoutFields.copyWith(...)`.
class _$_PrivateWithNullableWithoutFieldsCWProxyImpl<T extends Iterable<int>>
    implements _$_PrivateWithNullableWithoutFieldsCWProxy<T> {
  const _$_PrivateWithNullableWithoutFieldsCWProxyImpl(this._value);

  final _PrivateWithNullableWithoutFields<T> _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// _PrivateWithNullableWithoutFields<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  _PrivateWithNullableWithoutFields<T> call({
    Object? nullable = const $CopyWithPlaceholder(),
  }) {
    return _PrivateWithNullableWithoutFields<T>(
      nullable: nullable == const $CopyWithPlaceholder()
          ? _value.nullable
          // ignore: cast_nullable_to_non_nullable
          : nullable as T?,
    );
  }
}

extension _$_PrivateWithNullableWithoutFieldsCopyWith<T extends Iterable<int>>
    on _PrivateWithNullableWithoutFields<T> {
  /// Returns a callable class that can be used as follows: `instanceOf_PrivateWithNullableWithoutFields.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$_PrivateWithNullableWithoutFieldsCWProxy<T> get copyWith =>
      _$_PrivateWithNullableWithoutFieldsCWProxyImpl<T>(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// _PrivateWithNullableWithoutFields<T>(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  _PrivateWithNullableWithoutFields<T> copyWithNull({
    bool nullable = false,
  }) {
    return _PrivateWithNullableWithoutFields<T>(
      nullable: nullable == true ? null : this.nullable,
    );
  }
}
''')
@CopyWith(skipFields: true, copyWithNull: true)
// ignore: unused_element
class _PrivateWithNullableWithoutFields<T extends Iterable<int>> {
  const _PrivateWithNullableWithoutFields({this.nullable});

  final T? nullable;
}
