part of 'source_gen_entrypoint.dart';

@ShouldGenerate(r'''
/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfBasicClass.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfBasicClass.copyWith.fieldName(...)`
class _BasicClassCWProxy<T extends Iterable<int>> {
  final BasicClass<T> _value;

  const _BasicClassCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `BasicClass<T>(...).copyWithNull(...)` to set certain fields to `null`. Prefer `BasicClass<T>(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BasicClass<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  BasicClass<T> call({
    String? id,
    T? optional,
  }) {
    return BasicClass<T>(
      id: id ?? _value.id,
      immutable: _value.immutable,
      nullableImmutable: _value.nullableImmutable,
      optional: optional ?? _value.optional,
    );
  }

  BasicClass<T> optional(T? optional) => optional == null
      ? _value._copyWithNull(optional: true)
      : this(optional: optional);

  BasicClass<T> id(String id) => this(id: id);
}

extension BasicClassCopyWith<T extends Iterable<int>> on BasicClass<T> {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass BasicClass<T extends Iterable<int>>.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass BasicClass<T extends Iterable<int>>.name.copyWith.fieldName(...)`
  _BasicClassCWProxy<T> get copyWith => _BasicClassCWProxy<T>(this);

  BasicClass<T> _copyWithNull({
    bool optional = false,
  }) {
    return BasicClass<T>(
      id: id,
      immutable: immutable,
      nullableImmutable: nullableImmutable,
      optional: optional == true ? null : this.optional,
    );
  }
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
