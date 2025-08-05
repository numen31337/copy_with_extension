import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, ConstructorElement2;
import 'package:copy_with_extension_gen/src/constructor_field_resolver.dart';
import 'package:copy_with_extension_gen/src/element_utils.dart';
import 'package:copy_with_extension_gen/src/field_info.dart';
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
  }) {
    final targetConstructor = constructor != null
        ? element.getNamedConstructor2(constructor)
        : element.unnamedConstructor2;

    if (targetConstructor is! ConstructorElement2) {
      if (constructor != null) {
        throw InvalidGenerationSourceError(
          'Named Constructor "$constructor" constructor is missing.',
          element: element,
        );
      } else {
        throw InvalidGenerationSourceError(
          'Default constructor for $element is missing.',
          element: element,
        );
      }
    }

    final parameters = targetConstructor.formalParameters;
    if (parameters.isEmpty) {
      throw InvalidGenerationSourceError(
        'Unnamed constructor for $element has no parameters or missing.',
        element: element,
      );
    }
    final resolver = ConstructorFieldResolver(element, targetConstructor);
    final fields = <ConstructorParameterInfo>[];

    for (final parameter in parameters) {
      final paramName = ElementUtils.readElementNameOrThrow(parameter);
      final fieldName = resolver.resolve(paramName);

      final field = ConstructorParameterInfo(
        parameter,
        element,
        isPositioned: parameter.isPositional,
        annotatedSuper: annotatedSuper,
        fieldName: fieldName,
      );

      if (field.classFieldInfo != null) {
        fields.add(field);
      }
    }

    return fields;
  }

  /// Returns constructor for the given type and optional named constructor
  /// name. E.g. `TestConstructor` or `TestConstructor._private` when `_private`
  /// constructor name is provided.
  static String constructorFor(
          String typeAnnotation, String? namedConstructor) =>
      "$typeAnnotation${namedConstructor == null ? "" : ".$namedConstructor"}";
}
