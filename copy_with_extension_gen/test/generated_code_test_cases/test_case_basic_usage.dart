part of 'source_gen_entrypoint.dart';

@ShouldGenerate(r'''
abstract class _$BasicClassCWProxy<T extends Iterable<int>> {
  BasicClass<T> id(String id);

  BasicClass<T> optional(T? optional);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BasicClass<T>(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BasicClass<T>(...).copyWith(id: 12, name: "My name")
  /// ```
  BasicClass<T> call({String id, T? optional});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBasicClass.copyWith(...)` or call `instanceOfBasicClass.copyWith.fieldName(value)` for a single field.
class _$BasicClassCWProxyImpl<T extends Iterable<int>>
    implements _$BasicClassCWProxy<T> {
  const _$BasicClassCWProxyImpl(this._value);

  final BasicClass<T> _value;

  @override
  BasicClass<T> id(String id) => this(id: id);

  @override
  BasicClass<T> optional(T? optional) => this(optional: optional);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BasicClass<T>(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BasicClass<T>(...).copyWith(id: 12, name: "My name")
  /// ```
  BasicClass<T> call({
    Object? id = const $CopyWithPlaceholder(),
    Object? optional = const $CopyWithPlaceholder(),
  }) {
    return BasicClass<T>(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      optional: optional == const $CopyWithPlaceholder()
          ? _value.optional
          // ignore: cast_nullable_to_non_nullable
          : optional as T?,
      immutable: _value.immutable,
      nullableImmutable: _value.nullableImmutable,
    );
  }
}

extension $BasicClassCopyWith<T extends Iterable<int>> on BasicClass<T> {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBasicClass.copyWith(...)` or `instanceOfBasicClass.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BasicClassCWProxy<T> get copyWith => _$BasicClassCWProxyImpl<T>(this);
}
''')
@CopyWith()
class BasicClass<T extends Iterable<int>> {
  const BasicClass({
    required this.id,
    this.optional,
    required this.immutable,
    required this.nullableImmutable,
  });

  final String id;
  final T? optional;
  @CopyWithField(immutable: true)
  final int immutable;
  @CopyWithField(immutable: true)
  final int nullableImmutable;
}
