import 'package:analyzer/dart/element/element.dart' show ClassElement;

/// Configuration for resolving constructor parameters into field metadata.
///
/// Bundles the settings that flow together through [ConstructorUtils],
/// [ConstructorParameterInfoFactory], and [_ResolvedConstructorField] so
/// callers pass a single object instead of threading individual parameters.
class FieldResolutionConfig {
  const FieldResolutionConfig({
    required this.annotations,
    required this.immutableDefault,
    this.annotatedSuper,
  });

  /// Annotation names to forward from class fields to generated parameters.
  final Set<String> annotations;

  /// Whether fields are treated as immutable by default.
  final bool immutableDefault;

  /// The nearest superclass annotated with `@CopyWith`, if any.
  /// Used to determine whether a field is inherited through the proxy chain.
  final ClassElement? annotatedSuper;
}
