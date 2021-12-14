/// Provides annotation class to use with
/// [copy_with_extension_gen](https://pub.dev/packages/copy_with_extension_gen).
library copy_with_extension;

/// Annotation used to indicate that the `copyWith` extension should be generated.
class CopyWith {
  const CopyWith({
    this.copyWithValues = false,
    this.copyWithNull = false,
    this.copyWith = true,
    this.namedConstructor,
  });

  /// Set `copyWithValues` to `true` to generate the `copyWithValues` function, which allows to override multiple fields at once. This function does not support nullification of optional types, and all `null` values passed to this function will be ignored. For nullification, use `copyWithNull` to set certain fields to `null` or `copyWith` to override fields one at a time with nullification support.
  final bool copyWithValues;

  /// Set `copyWithNull` to `true` for generating `copyWithNull` function that allows you to nullify the fields.
  final bool copyWithNull;

  /// Set `copyWith` to `true` to generate `copyWith`. It will provide you with a `copyWith` functionality and support for nullability.
  final bool copyWith;

  /// Set `namedConstructor` if you want to use a named constructor instead. The generated fields will be derived from this constructor.
  final String? namedConstructor;
}

/// Additional field related options for the `CopyWith`.
class CopyWithField {
  const CopyWithField({this.immutable = false});

  /// Indicates that the field should be hidden in the generated `copyWith` method. By setting this flag to `true` the property will always be copied as it is e.g. `userID` field.
  final bool immutable;
}
