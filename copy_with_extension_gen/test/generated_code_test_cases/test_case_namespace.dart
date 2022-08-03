part of 'source_gen_entrypoint.dart';

class ByteBuffer {}

@ShouldGenerate(r'''
abstract class _$NamespaceTestClassCWProxy {
  NamespaceTestClass namespacedProperty(td.ByteBuffer namespacedProperty);

  NamespaceTestClass regularProperty(ByteBuffer regularProperty);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NamespaceTestClass(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NamespaceTestClass(...).copyWith(id: 12, name: "My name")
  /// ````
  NamespaceTestClass call({
    td.ByteBuffer? namespacedProperty,
    ByteBuffer? regularProperty,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNamespaceTestClass.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNamespaceTestClass.copyWith.fieldName(...)`
class _$NamespaceTestClassCWProxyImpl implements _$NamespaceTestClassCWProxy {
  final NamespaceTestClass _value;

  const _$NamespaceTestClassCWProxyImpl(this._value);

  @override
  NamespaceTestClass namespacedProperty(td.ByteBuffer namespacedProperty) =>
      this(namespacedProperty: namespacedProperty);

  @override
  NamespaceTestClass regularProperty(ByteBuffer regularProperty) =>
      this(regularProperty: regularProperty);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NamespaceTestClass(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NamespaceTestClass(...).copyWith(id: 12, name: "My name")
  /// ````
  NamespaceTestClass call({
    Object? namespacedProperty = const $CopyWithPlaceholder(),
    Object? regularProperty = const $CopyWithPlaceholder(),
  }) {
    return NamespaceTestClass(
      namespacedProperty: namespacedProperty == const $CopyWithPlaceholder() ||
              namespacedProperty == null
          ? _value.namespacedProperty
          // ignore: cast_nullable_to_non_nullable
          : namespacedProperty as td.ByteBuffer,
      regularProperty: regularProperty == const $CopyWithPlaceholder() ||
              regularProperty == null
          ? _value.regularProperty
          // ignore: cast_nullable_to_non_nullable
          : regularProperty as ByteBuffer,
    );
  }
}

extension $NamespaceTestClassCopyWith on NamespaceTestClass {
  /// Returns a callable class that can be used as follows: `instanceOfNamespaceTestClass.copyWith(...)` or like so:`instanceOfNamespaceTestClass.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NamespaceTestClassCWProxy get copyWith =>
      _$NamespaceTestClassCWProxyImpl(this);
}
''')
@CopyWith()
class NamespaceTestClass {
  final td.ByteBuffer namespacedProperty;
  final ByteBuffer regularProperty;

  NamespaceTestClass({
    required this.namespacedProperty,
    required this.regularProperty,
  });
}
