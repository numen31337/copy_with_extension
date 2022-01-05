part of 'source_gen_entrypoint.dart';

@ShouldGenerate(r'''
abstract class _$BasicClassCWProxy<T extends Iterable<int>> {
  BasicClass<T> id(String id);

  BasicClass<T> optional(T? optional);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BasicClass<T>(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BasicClass<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  BasicClass<T> call({
    String? id,
    T? optional,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBasicClass.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBasicClass.copyWith.fieldName(...)`
class _$BasicClassCWProxyImpl<T extends Iterable<int>>
    implements _$BasicClassCWProxy<T> {
  final BasicClass<T> _value;

  const _$BasicClassCWProxyImpl(this._value);

  @override
  BasicClass<T> id(String id) => this(id: id);

  @override
  BasicClass<T> optional(T? optional) => this(optional: optional);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BasicClass<T>(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BasicClass<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  BasicClass<T> call({
    Object? id = const $CopyWithPlaceholder(),
    Object? optional = const $CopyWithPlaceholder(),
  }) {
    return BasicClass<T>(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      immutable: _value.immutable,
      nullableImmutable: _value.nullableImmutable,
      optional: optional == const $CopyWithPlaceholder()
          ? _value.optional
          // ignore: cast_nullable_to_non_nullable
          : optional as T?,
    );
  }
}

extension $BasicClassCopyWith<T extends Iterable<int>> on BasicClass<T> {
  /// Returns a callable class that can be used as follows: `instanceOfclass BasicClass<T extends Iterable<int>>.name.copyWith(...)` or like so:`instanceOfclass BasicClass<T extends Iterable<int>>.name.copyWith.fieldName(...)`.
  _$BasicClassCWProxy<T> get copyWith => _$BasicClassCWProxyImpl<T>(this);
}
''')
@CopyWith()
class BasicClass<T extends Iterable<int>> {
  final String id;
  final T? optional;
  @CopyWithField(immutable: true)
  final int immutable;
  @CopyWithField(immutable: true)
  final int nullableImmutable;

  const BasicClass({
    required this.id,
    this.optional,
    required this.immutable,
    required this.nullableImmutable,
  });
}
