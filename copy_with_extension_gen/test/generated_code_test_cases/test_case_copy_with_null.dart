part of 'source_gen_entrypoint.dart';

@ShouldGenerate(r'''
abstract class _$WithNullableWithoutFieldsCWProxy<T extends Iterable<int>> {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WithNullableWithoutFields<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  WithNullableWithoutFields<T> call({
    T? nullable,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWithNullableWithoutFields.copyWith(...)`.
class _$WithNullableWithoutFieldsCWProxyImpl<T extends Iterable<int>>
    implements _$WithNullableWithoutFieldsCWProxy<T> {
  final WithNullableWithoutFields<T> _value;

  const _$WithNullableWithoutFieldsCWProxyImpl(this._value);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WithNullableWithoutFields<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  WithNullableWithoutFields<T> call({
    Object? nullable = const $CopyWithPlaceholder(),
  }) {
    return WithNullableWithoutFields<T>(
      nullable: nullable == const $CopyWithPlaceholder()
          ? _value.nullable
          // ignore: cast_nullable_to_non_nullable
          : nullable as T?,
    );
  }
}

extension $WithNullableWithoutFieldsCopyWith<T extends Iterable<int>>
    on WithNullableWithoutFields<T> {
  /// Returns a callable class that can be used as follows: `instanceOfclass WithNullableWithoutFields<T extends Iterable<int>>.name.copyWith(...)`.
  _$WithNullableWithoutFieldsCWProxy<T> get copyWith =>
      _$WithNullableWithoutFieldsCWProxyImpl<T>(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// WithNullableWithoutFields<T>(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  WithNullableWithoutFields<T> copyWithNull({
    bool nullable = false,
  }) {
    return WithNullableWithoutFields<T>(
      nullable: nullable == true ? null : this.nullable,
    );
  }
}
''')
@CopyWith(skipFields: true, copyWithNull: true)
class WithNullableWithoutFields<T extends Iterable<int>> {
  final T? nullable;

  const WithNullableWithoutFields({this.nullable});
}
