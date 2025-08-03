import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
abstract class _$BasicClassCWProxy<T extends Iterable<int>> {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// BasicClass<T>(...).copyWith(id: 12, name: "My name")
  /// ```
  BasicClass<T> call({String id, T? optional});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBasicClass.copyWith(...)`.
class _$BasicClassCWProxyImpl<T extends Iterable<int>>
    implements _$BasicClassCWProxy<T> {
  const _$BasicClassCWProxyImpl(this._value);

  final BasicClass<T> _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
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
      id: id == const $CopyWithPlaceholder() || id == null
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
  /// Example: `instanceOfBasicClass.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$BasicClassCWProxy<T> get copyWith => _$BasicClassCWProxyImpl<T>(this);

  /// Returns a copy of the object with the selected fields set to `null`.
  /// A flag set to `false` leaves the field unchanged. Prefer `copyWith(field: null)`.
  ///
  /// Example:
  /// ```dart
  /// BasicClass<T>(...).copyWithNull(firstField: true, secondField: true)
  /// ```
  BasicClass<T> copyWithNull({bool optional = false}) {
    return BasicClass<T>(
      id: id,
      optional: optional == true ? null : this.optional,
      immutable: immutable,
      nullableImmutable: nullableImmutable,
    );
  }
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
