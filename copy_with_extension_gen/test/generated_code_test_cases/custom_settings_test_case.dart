import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
// ignore_for_file: unnecessary_non_null_assertion, duplicate_ignore

abstract class _$BasicClassCWProxy<T extends Iterable<int>> {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
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

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBasicClass.copyWith(...)`.
class _$BasicClassCWProxyImpl<T extends Iterable<int>>
    implements _$BasicClassCWProxy<T> {
  const _$BasicClassCWProxyImpl(this._value);

  final BasicClass<T> _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
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
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id!
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
  /// Returns a callable class that can be used as follows: `instanceOfBasicClass.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$BasicClassCWProxy<T> get copyWith => _$BasicClassCWProxyImpl<T>(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// BasicClass<T>(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  BasicClass<T> copyWithNull({
    bool optional = false,
  }) {
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
