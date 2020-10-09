/// Provides annotation class to use with
/// [copy_with_extension_gen](https://pub.dev/packages/copy_with_extension_gen).
library copy_with_extension;

/// Annotation used to indicate that the `copyWith` extension should be generated.
class CopyWith {
  /// Creates a new [CopyWith] instance.
  /// Set `generateCopyWithNull` to `true` for generating an extra `copyWithNull` function that allows you to nullify the properties.
  const CopyWith({this.generateCopyWithNull = false})
      : assert(generateCopyWithNull is bool);

  final bool generateCopyWithNull;
}

/// Additional field related options for the `CopyWith`.
class CopyWithField {
  const CopyWithField({this.immutable = false}) : assert(immutable is bool);

  /// Indicates that the field should be hidden in the generated `copyWith` method. By setting this flag to `true` the property will always be copied as it is e.g. `userID` field.
  final bool immutable;
}
