import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, Element2;
import 'package:build/build.dart' show BuildStep;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/annotation_utils.dart';
import 'package:copy_with_extension_gen/src/constructor_utils.dart';
import 'package:copy_with_extension_gen/src/element_utils.dart';
import 'package:copy_with_extension_gen/src/inheritance.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:copy_with_extension_gen/src/templates/extension_template.dart';
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

    final classAnnotation = AnnotationUtils.readClassAnnotation(
      settings,
      annotation,
    );
    final className = ElementUtils.readElementNameOrThrow(element);

    // Locate the nearest annotated superclass before gathering fields so
    // inherited parameters can be tracked relative to that superclass only.
    var superInfo = findAnnotatedSuper(element);

    // When `skipFields` is enabled and the closest annotated superclass is not
    // the direct parent, avoid proxy inheritance to ensure field-specific
    // methods from ancestors are not exposed.
    if (classAnnotation.skipFields &&
        superInfo != null &&
        element.supertype?.element3 != superInfo.element) {
      superInfo = null;
    }

    final fields = ConstructorUtils.constructorFields(
      element,
      classAnnotation.constructor,
      annotatedSuper: superInfo?.element,
    );

    if (superInfo != null) {
      final superFields = ConstructorUtils.constructorFields(
        superInfo.element,
        superInfo.constructor,
      ).where((f) => !f.fieldAnnotation.immutable).map((f) => f.name).toSet();
      final fieldNames = fields.map((e) => e.name).toSet();
      if (!fieldNames.containsAll(superFields)) {
        superInfo = null;
      }
    }
    final typeParametersAnnotation = ElementUtils.typeParametersString(
      element,
      false,
    );
    final typeParametersNames = ElementUtils.typeParametersString(
      element,
      true,
    );

    // Verify that constructor and class field nullability match. The generator
    // does not support a non-nullable constructor parameter pointing to a
    // nullable class field.
    for (final field in fields) {
      if (field.classField != null &&
          field.nullable == false &&
          field.classFieldNullable) {
        throw InvalidGenerationSourceError(
          'The constructor parameter "${field.name}" is not nullable, whereas the corresponding class field is nullable. This use case is not supported.',
          element: element,
        );
      }
    }

    var generateCopyWithNull = classAnnotation.copyWithNull;
    if (!generateCopyWithNull &&
        superInfo?.copyWithNull == true &&
        fields.any((f) => f.nullable && !f.fieldAnnotation.immutable)) {
      generateCopyWithNull = true;
    }

    return extensionTemplate(
      isPrivate: element.isPrivate,
      className: className,
      typeParametersAnnotation: typeParametersAnnotation,
      typeParametersNames: typeParametersNames,
      fields: fields,
      skipFields: classAnnotation.skipFields,
      copyWithNull: generateCopyWithNull,
      constructor: classAnnotation.constructor,
      superInfo: superInfo,
    );
  }
}
