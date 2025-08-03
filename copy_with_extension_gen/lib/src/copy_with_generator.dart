import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, Element2;
import 'package:build/build.dart' show BuildStep;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/helpers.dart';
import 'package:copy_with_extension_gen/src/inheritance.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:copy_with_extension_gen/src/templates.dart';
import 'package:source_gen/source_gen.dart'
    show ConstantReader, GeneratorForAnnotation, InvalidGenerationSourceError;

/// Builds `copyWith` extensions for classes annotated with `@CopyWith`.
class CopyWithGenerator extends GeneratorForAnnotation<CopyWith> {
  CopyWithGenerator(this.settings) : super();

  Settings settings;

  /// Generates the `copyWith` extension code for the annotated [element].
  ///
  /// The method validates the target class, gathers all constructor
  /// parameters and user provided settings, and returns the source code for
  /// the extension as a string.
  @override
  String generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement2) {
      throw InvalidGenerationSourceError(
        'Only classes can be annotated with "CopyWith". "$element" is not a ClassElement.',
        element: element,
      );
    }

    final classAnnotation = readClassAnnotation(settings, annotation);
    final className = readElementNameOrThrow(element);

    // Locate the nearest annotated superclass before gathering fields so
    // inherited parameters can be tracked relative to that superclass only.
    var superInfo = findAnnotatedSuper(element);

    final fields = constructorFields(
      element,
      classAnnotation.constructor,
      annotatedSuper: superInfo?.element,
    );

    if (superInfo != null) {
      final superCtor = superInfo.constructor != null
          ? superInfo.element.getNamedConstructor2(superInfo.constructor!)
          : superInfo.element.unnamedConstructor2;
      final requiredParams = superCtor?.formalParameters
              .where((p) => p.isRequiredNamed || p.isRequiredPositional)
              .map((p) => readElementNameOrThrow(p))
              .toSet() ??
          {};
      final fieldNames = fields.map((e) => e.name).toSet();
      if (!fieldNames.containsAll(requiredParams)) {
        superInfo = null;
      }
    }
    final typeParametersAnnotation = typeParametersString(element, false);
    final typeParametersNames = typeParametersString(element, true);

    // Verify that constructor and class field nullability match. The generator
    // does not support a non-nullable constructor parameter pointing to a
    // nullable class field.
    for (final field in fields) {
      if (field.classFieldInfo != null &&
          field.nullable == false &&
          field.classFieldInfo?.nullable == true) {
        throw InvalidGenerationSourceError(
          'The constructor parameter "${field.name}" is not nullable, whereas the corresponding class field is nullable. This use case is not supported.',
          element: element,
        );
      }
    }

    return extensionTemplate(
      isPrivate: element.isPrivate,
      className: className,
      typeParametersAnnotation: typeParametersAnnotation,
      typeParametersNames: typeParametersNames,
      fields: fields,
      skipFields: classAnnotation.skipFields,
      copyWithNull: classAnnotation.copyWithNull,
      constructor: classAnnotation.constructor,
      superInfo: superInfo,
    );
  }
}
