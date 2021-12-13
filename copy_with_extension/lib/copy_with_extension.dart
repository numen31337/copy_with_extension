/// Provides annotation class to use with
/// [copy_with_extension_gen](https://pub.dev/packages/copy_with_extension_gen).
library copy_with_extension;

/// Annotation used to indicate that the `copyWith` extension should be generated.
class CopyWith {
  /// Creates a new [CopyWith] instance.
  const CopyWith({
    this.generateCopyWithNull = false,
    this.namedConstructor,
  });

  /// Set `generateCopyWithNull` to `true` for generating an extra `copyWithNull` function that allows you to nullify the properties.
  final bool generateCopyWithNull;

  /// Set `namedConstructor` if you want to use a named constructor instead.
  final String? namedConstructor;
}

/// Additional field related options for the `CopyWith`.
class CopyWithField {
  const CopyWithField({this.immutable = false});

  /// Indicates that the field should be hidden in the generated `copyWith` method. By setting this flag to `true` the property will always be copied as it is e.g. `userID` field.
  final bool immutable;
}
