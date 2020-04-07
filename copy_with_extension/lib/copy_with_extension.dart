/// Provides annotation class to use with
/// [copy_with_extension_gen](https://pub.dev/packages/copy_with_extension_gen).
library copy_with_extension;

/// Annotation used to indicate that the `copyWith` extension should be generated.
class CopyWith {
  /// Creates a new [CopyWith] instance.
  const CopyWith({this.generateCopyWithNull = false})
      : assert(generateCopyWithNull is bool);

  final bool generateCopyWithNull;
}
