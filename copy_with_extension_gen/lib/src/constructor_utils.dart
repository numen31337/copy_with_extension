import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, ConstructorElement2;
import 'package:copy_with_extension_gen/src/constructor_field_resolver.dart';
import 'package:copy_with_extension_gen/src/element_utils.dart';
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
  }) {
    final targetConstructor = constructor != null
        ? element.getNamedConstructor2(constructor)
        : element.unnamedConstructor2;

    if (targetConstructor is! ConstructorElement2) {
      final className = ElementUtils.readElementNameOrThrow(element);
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

    final parameters = targetConstructor.formalParameters;
    if (parameters.isEmpty) {
      final className = ElementUtils.readElementNameOrThrow(element);
      throw InvalidGenerationSourceError(
        'The unnamed constructor of class $className must declare at least one parameter.',
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
        annotations: annotations,
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

  /// Returns constructor for the given type and optional named constructor
  /// name. E.g. `TestConstructor` or `TestConstructor._private` when `_private`
  /// constructor name is provided.
  static String constructorFor(
    String typeAnnotation,
    String? namedConstructor,
  ) =>
      "$typeAnnotation${namedConstructor == null ? "" : ".$namedConstructor"}";
}
