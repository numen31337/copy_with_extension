part of 'source_gen_entrypoint.dart';

@ShouldGenerate(r'''
abstract class _$_PrivateWithNullableWithoutFieldsCWProxy<
  T extends Iterable<int>
> {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// _PrivateWithNullableWithoutFields<T>(...).copyWith(id: 12, name: "My name")
  /// ```
  _PrivateWithNullableWithoutFields<T> call({T? nullable});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOf_PrivateWithNullableWithoutFields.copyWith(...)`.
class _$_PrivateWithNullableWithoutFieldsCWProxyImpl<T extends Iterable<int>>
    implements _$_PrivateWithNullableWithoutFieldsCWProxy<T> {
  const _$_PrivateWithNullableWithoutFieldsCWProxyImpl(this._value);

  final _PrivateWithNullableWithoutFields<T> _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// _PrivateWithNullableWithoutFields<T>(...).copyWith(id: 12, name: "My name")
  /// ```
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
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOf_PrivateWithNullableWithoutFields.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$_PrivateWithNullableWithoutFieldsCWProxy<T> get copyWith =>
      _$_PrivateWithNullableWithoutFieldsCWProxyImpl<T>(this);

  /// Returns a copy of the object with the selected fields set to `null`.
  /// A flag set to `false` leaves the field unchanged. Prefer `copyWith(field: null)`.
  ///
  /// Example:
  /// ```dart
  /// _PrivateWithNullableWithoutFields<T>(...).copyWithNull(firstField: true, secondField: true)
  /// ```
  _PrivateWithNullableWithoutFields<T> copyWithNull({bool nullable = false}) {
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
