part of 'source_gen_entrypoint.dart';

@ShouldGenerate(r'''
class _WithNullableWithoutFields_CWProxy<T extends Iterable<int>> {
  final WithNullableWithoutFields<T> _value;

  const _WithNullableWithoutFields_CWProxy(this._value);

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
  _WithNullableWithoutFields_CWProxy<T> get copyWith =>
      _WithNullableWithoutFields_CWProxy<T>(this);

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
@immutable
@CopyWith(skipFields: true, copyWithNull: true)
class WithNullableWithoutFields<T extends Iterable<int>> {
  final T? nullable;

  const WithNullableWithoutFields({this.nullable});
}
