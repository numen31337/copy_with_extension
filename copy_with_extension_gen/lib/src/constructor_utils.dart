import 'package:analyzer/dart/element/element.dart'
    show ClassElement, ConstructorElement, FormalParameterElement;
import 'package:copy_with_extension_gen/src/class_field_lookup.dart';
import 'package:copy_with_extension_gen/src/constructor_field_resolver.dart';
import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:copy_with_extension_gen/src/field_resolution_config.dart';
import 'package:source_gen/source_gen.dart' show InvalidGenerationSourceError;

/// Utilities related to constructors.
class ConstructorUtils {
  const ConstructorUtils._();

  /// Generates a list of [ConstructorParameterInfo] objects representing the
  /// constructor parameters that participate in `copyWith` generation.
  ///
  /// Will throw an [InvalidGenerationSourceError] if the constructor cannot be
  /// resolved or has no parameters.
  static Future<ConstructorFieldsResult> constructorFields(
    ClassElement element,
    String? constructor,
    FieldResolutionConfig config,
  ) async {
    final targetConstructor =
        constructor != null
            ? element.getNamedConstructor(constructor)
            : element.unnamedConstructor;

    if (targetConstructor is! ConstructorElement) {
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
    final resolvedName = resolvedConstructor.name;
    final constructorName = resolvedName == 'new' ? null : resolvedName;
    final parameters = resolvedConstructor.formalParameters;
    if (parameters.isEmpty) {
      final className = element.displayName;
      if (constructor != null) {
        throw InvalidGenerationSourceError(
          'The constructor "$constructor" of class $className has no parameters. copyWith generation requires at least one constructor parameter.',
          element: element,
        );
      } else {
        throw InvalidGenerationSourceError(
          'The unnamed constructor of class $className has no parameters. copyWith generation requires at least one constructor parameter.',
          element: element,
        );
      }
    }
    final fieldLookup = ClassFieldLookupCache(element);
    final resolver = await ConstructorFieldResolver.create(
      element,
      resolvedConstructor,
      fieldLookup: fieldLookup,
    );
    final parameterInfoFactory = ConstructorParameterInfoFactory(
      classElement: element,
      config: config,
      fieldLookup: fieldLookup,
    );
    final fields = <ConstructorParameterInfo>[];

    for (final parameter in parameters) {
      final paramName = parameter.displayName;
      final fieldName = resolver.resolve(paramName);
      if (fieldName == null) {
        if (resolver.hasBindingEvidence(paramName) ||
            parameter.isRequired ||
            fieldLookup.exists(paramName)) {
          _throwUnresolvedFieldParameter(element, parameter);
        }
        continue;
      }

      final field = parameterInfoFactory.create(
        parameter,
        isPositioned: parameter.isPositional,
        fieldName: fieldName,
      );

      final classField = field.classField;
      final isAccessible =
          classField != null &&
          (!classField.isPrivate || classField.library == element.library);
      if (!isAccessible && parameter.isRequired) {
        _throwUnresolvedFieldParameter(element, parameter);
      }
      if (isAccessible) {
        fields.add(field);
      }
    }

    return ConstructorFieldsResult(
      fields: fields,
      constructorName: constructorName,
    );
  }

  static Never _throwUnresolvedFieldParameter(
    ClassElement element,
    FormalParameterElement parameter,
  ) {
    throw InvalidGenerationSourceError(
      'Constructor parameter "${parameter.displayName}" in class '
      '${element.displayName} could not be resolved to exactly one accessible '
      'class field. copyWith generation requires constructor parameters that '
      'set fields to map directly to one field.',
      element: parameter,
    );
  }

  /// Follows redirecting or factory constructors until the final generative
  /// constructor is reached.
  ///
  /// Ensures that only constructors belonging to [element] are considered in
  /// order to avoid traversing into other classes.
  static ConstructorElement resolveRedirects(
    ClassElement element,
    ConstructorElement constructor,
  ) {
    var current = constructor;
    final seen = <ConstructorElement>{};
    while (seen.add(current)) {
      final redirected = current.redirectedConstructor;
      if (redirected == null || redirected.enclosingElement != element) {
        return current;
      }
      current = redirected;
    }
    return current;
  }
}

/// Result of [ConstructorUtils.constructorFields], bundling the resolved
/// constructor name alongside the parameter info list.
class ConstructorFieldsResult {
  const ConstructorFieldsResult({
    required this.fields,
    required this.constructorName,
  });

  /// Resolved constructor parameters participating in `copyWith` generation.
  final List<ConstructorParameterInfo> fields;

  /// The resolved constructor name, or `null` for the unnamed constructor.
  /// Redirect chains are already followed; the `'new'` sentinel is normalized
  /// to `null`.
  final String? constructorName;
}
