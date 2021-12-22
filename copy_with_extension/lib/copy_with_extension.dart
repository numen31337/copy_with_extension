/// Provides annotation class to use with
/// [copy_with_extension_gen](https://pub.dev/packages/copy_with_extension_gen).
library copy_with_extension;

/// Annotation used to indicate that the `copyWith` extension should be generated.
class CopyWith {
  const CopyWith({
    this.copyWithNull = false,
    this.skipFields = false,
    this.namedConstructor,
  });

  /// Set `copyWithNull` to `true` if you want to use `copyWithNull` function that allows you to nullify the fields. E.g. `myInstance.copyWithNull(id: true, name: true)`. Otherwise it will be still generated for internal use but marked as private.
  final bool copyWithNull;

  /// TODO: Info here
  final bool skipFields;

  /// Set `namedConstructor` if you want to use a named constructor instead. The generated fields will be derived from this constructor.
  final String? namedConstructor;
}

/// Additional field related options for the `CopyWith`.
class CopyWithField {
  const CopyWithField({this.immutable = false});

  /// Indicates that the field should be hidden in the generated `copyWith` method. By setting this flag to `true` the property will always be copied as it is e.g. `userID` field.
  final bool immutable;
}
