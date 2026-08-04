/// Configuration for resolving constructor parameters into field metadata.
///
/// Bundles the settings that flow together through `ConstructorUtils` and
/// `ConstructorParameterInfoFactory` so callers pass a single object instead
/// of threading individual parameters.
class FieldResolutionConfig {
  const FieldResolutionConfig({
    required this.annotations,
    required this.immutableDefault,
  });

  /// Annotation names to forward from class fields to generated parameters.
  final Set<String> annotations;

  /// Whether fields are treated as immutable by default.
  final bool immutableDefault;
}
