part of 'source_gen_entrypoint.dart';

@ShouldGenerate(r'''
abstract class _$PrefixedSubclassCWProxy {
  PrefixedSubclass superField(int superField);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PrefixedSubclass(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PrefixedSubclass(...).copyWith(id: 12, name: "My name")
  /// ```
  PrefixedSubclass call({int superField});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPrefixedSubclass.copyWith(...)` or call `instanceOfPrefixedSubclass.copyWith.fieldName(value)` for a single field.
class _$PrefixedSubclassCWProxyImpl implements _$PrefixedSubclassCWProxy {
  const _$PrefixedSubclassCWProxyImpl(this._value);

  final PrefixedSubclass _value;

  @override
  PrefixedSubclass superField(int superField) => call(superField: superField);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PrefixedSubclass(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PrefixedSubclass(...).copyWith(id: 12, name: "My name")
  /// ```
  PrefixedSubclass call({Object? superField = const $CopyWithPlaceholder()}) {
    return PrefixedSubclass(
      superField == const $CopyWithPlaceholder() || superField == null
          ? _value.superField
          // ignore: cast_nullable_to_non_nullable
          : superField as int,
    );
  }
}

extension $PrefixedSubclassCopyWith on PrefixedSubclass {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPrefixedSubclass.copyWith(...)` or `instanceOfPrefixedSubclass.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PrefixedSubclassCWProxy get copyWith => _$PrefixedSubclassCWProxyImpl(this);
}
''')
@CopyWith()
class PrefixedSubclass extends a.PrefixedSuper<int> {
  const PrefixedSubclass(super.superField);
}
