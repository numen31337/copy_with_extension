part of 'source_gen_entrypoint.dart';

@ShouldGenerate(r'''
abstract class _$BasicChildCWProxy extends _$BasicClassCWProxy<Iterable<int>> {
  BasicChild childField(String childField);

  @override
  BasicChild id(String id);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BasicChild(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BasicChild(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  BasicChild call({String childField, String id});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBasicChild.copyWith(...)` or call `instanceOfBasicChild.copyWith.fieldName(value)` for a single field.
class _$BasicChildCWProxyImpl extends _$BasicClassCWProxyImpl<Iterable<int>>
    implements _$BasicChildCWProxy {
  const _$BasicChildCWProxyImpl(this._value) : super(_value);

  @override
  // ignore: overridden_fields
  final BasicChild _value;

  @override
  BasicChild childField(String childField) => this(childField: childField);

  @override
  BasicChild id(String id) => this(id: id);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BasicChild(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BasicChild(...).copyWith(id: 12, name: "My name")
  /// ```
  BasicChild call({
    Object? childField = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
  }) {
    return BasicChild(
      childField == const $CopyWithPlaceholder()
          ? _value.childField
          // ignore: cast_nullable_to_non_nullable
          : childField as String,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      immutable: _value.immutable,
      nullableImmutable: _value.nullableImmutable,
    );
  }
}

extension $BasicChildCopyWith on BasicChild {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBasicChild.copyWith(...)` or `instanceOfBasicChild.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BasicChildCWProxy get copyWith => _$BasicChildCWProxyImpl(this);
}
''')
@CopyWith()
class BasicChild extends BasicClass<Iterable<int>> {
  BasicChild(
    this.childField, {
    required super.id,
    required super.immutable,
    required super.nullableImmutable,
  });

  final String childField;
}
