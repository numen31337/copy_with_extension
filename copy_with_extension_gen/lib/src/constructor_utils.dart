import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, ConstructorElement2;
import 'package:copy_with_extension_gen/src/constructor_field_resolver.dart';
import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:source_gen/source_gen.dart' show InvalidGenerationSourceError;

/// Utilities related to constructors.
class ConstructorUtils {
  const ConstructorUtils._();

  /// Generates a list of [ConstructorParameterInfo] objects representing the
  /// constructor parameters that participate in `copyWith` generation.
  ///
  /// Will throw an [InvalidGenerationSourceError] if the constructor cannot be
  /// resolved or has no parameters.
  static List<ConstructorParameterInfo> constructorFields(
    ClassElement2 element,
    String? constructor, {
    ClassElement2? annotatedSuper,
    required Set<String> annotations,
    required bool immutableFields,
  }) {
    final targetConstructor = constructor != null
        ? element.getNamedConstructor2(constructor)
        : element.unnamedConstructor2;

    if (targetConstructor is! ConstructorElement2) {
      final className = element.displayName;
      if (constructor != null) {
        throw InvalidGenerationSourceError(
          'Could not find a constructor named "$constructor" in class $className.',
          element: element,
        );
      } else {
        throw InvalidGenerationSourceError(
          'Class $className must define an unnamed constructor to enable copyWith generation.',
          element: element,
        );
      }
    }

    final resolvedConstructor = resolveRedirects(element, targetConstructor);
    final parameters = resolvedConstructor.formalParameters;
    if (parameters.isEmpty) {
      final className = element.displayName;
      throw InvalidGenerationSourceError(
        'The unnamed constructor of class $className must declare at least one parameter.',
        element: element,
      );
    }
    final resolver = ConstructorFieldResolver(element, resolvedConstructor);
    final fields = <ConstructorParameterInfo>[];

    for (final parameter in parameters) {
      final paramName = parameter.displayName;
      final fieldName = resolver.resolve(paramName);

      final field = ConstructorParameterInfo(
        parameter,
        element,
        isPositioned: parameter.isPositional,
        annotatedSuper: annotatedSuper,
        fieldName: fieldName,
        annotations: annotations,
        immutableDefault: immutableFields,
      );

      final classField = field.classField;
      final isAccessible = classField != null &&
          (!classField.isPrivate || classField.library2 == element.library2);
      if (isAccessible) {
        fields.add(field);
      }
    }

    return fields;
  }

  /// Follows redirecting or factory constructors until the final generative
  /// constructor is reached.
  ///
  /// Ensures that only constructors belonging to [element] are considered in
  /// order to avoid traversing into other classes.
  static ConstructorElement2 resolveRedirects(
    ClassElement2 element,
    ConstructorElement2 constructor,
  ) {
    var current = constructor;
    final seen = <ConstructorElement2>{};
    while (seen.add(current)) {
      final redirected = current.redirectedConstructor2;
      if (redirected == null || redirected.enclosingElement2 != element) {
        return current;
      }
      current = redirected;
    }
    return current;
  }

  /// Returns constructor for the given type and optional named constructor
  /// name. E.g. `TestConstructor` or `TestConstructor._private` when `_private`
  /// constructor name is provided.
  static String constructorFor(
    String typeAnnotation,
    String? namedConstructor,
  ) =>
      "$typeAnnotation${namedConstructor == null ? "" : ".$namedConstructor"}";
}
