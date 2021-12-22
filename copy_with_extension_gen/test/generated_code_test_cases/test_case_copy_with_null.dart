part of 'source_gen_entrypoint.dart';

@ShouldGenerate(r'''
/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfWithNullableWithoutFields.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored.
class _WithNullableWithoutFieldsCWProxy<T extends Iterable<int>> {
  final WithNullableWithoutFields<T> _value;

  const _WithNullableWithoutFieldsCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `WithNullableWithoutFields<T>(...).copyWithNull(...)` to set certain fields to `null`.
  ///
  /// Usage
  /// ```dart
  /// WithNullableWithoutFields<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  WithNullableWithoutFields<T> call({
    T? nullable,
  }) {
    return WithNullableWithoutFields<T>(
      nullable: nullable ?? _value.nullable,
    );
  }
}

extension WithNullableWithoutFieldsCopyWith<T extends Iterable<int>>
    on WithNullableWithoutFields<T> {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass WithNullableWithoutFields<T extends Iterable<int>>.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored.
  _WithNullableWithoutFieldsCWProxy<T> get copyWith =>
      _WithNullableWithoutFieldsCWProxy<T>(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it.
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
