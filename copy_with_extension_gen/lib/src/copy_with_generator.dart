import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, Element2;
import 'package:build/build.dart' show BuildStep;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/annotation_utils.dart';
import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:copy_with_extension_gen/src/constructor_utils.dart';
import 'package:copy_with_extension_gen/src/copy_with_annotation.dart';
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
    final classElement = _expectClassElement(element);
    final classAnnotation =
        AnnotationUtils.readClassAnnotation(settings, annotation);
    final className = ElementUtils.readElementNameOrThrow(classElement);
    var superInfo = _findSuperInfo(classElement, classAnnotation);
    final fields = ConstructorUtils.constructorFields(
      classElement,
      classAnnotation.constructor,
      annotatedSuper: superInfo?.element,
    );
    superInfo = _validateSuperFields(superInfo, fields);
    _validateFieldNullability(fields, classElement);

    final typeParametersAnnotation =
        ElementUtils.typeParametersString(classElement, false);
    final typeParametersNames =
        ElementUtils.typeParametersString(classElement, true);

    final generateCopyWithNull = _shouldGenerateCopyWithNull(
      classAnnotation.copyWithNull,
      superInfo,
      fields,
    );

    return extensionTemplate(
      isPrivate: classElement.isPrivate,
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

  ClassElement2 _expectClassElement(Element2 element) {
    if (element is ClassElement2) {
      return element;
    }
    throw InvalidGenerationSourceError(
      'Only classes can be annotated with "CopyWith". "$element" is not a ClassElement.',
      element: element,
    );
  }

  AnnotatedCopyWithSuper? _findSuperInfo(
    ClassElement2 element,
    CopyWithAnnotation annotation,
  ) {
    var superInfo = findAnnotatedSuper(element);
    if (annotation.skipFields &&
        superInfo != null &&
        element.supertype?.element3 != superInfo.element) {
      superInfo = null;
    }
    return superInfo;
  }

  AnnotatedCopyWithSuper? _validateSuperFields(
    AnnotatedCopyWithSuper? superInfo,
    List<ConstructorParameterInfo> fields,
  ) {
    if (superInfo != null) {
      final superFields = ConstructorUtils.constructorFields(
        superInfo.element,
        superInfo.constructor,
      ).where((f) => !f.fieldAnnotation.immutable).map((f) => f.name).toSet();
      final fieldNames = fields.map((e) => e.name).toSet();
      if (!fieldNames.containsAll(superFields)) {
        return null;
      }
    }
    return superInfo;
  }

  void _validateFieldNullability(
    List<ConstructorParameterInfo> fields,
    ClassElement2 classElement,
  ) {
    for (final field in fields) {
      if (field.classField != null &&
          field.nullable == false &&
          field.classFieldNullable) {
        throw InvalidGenerationSourceError(
          'The constructor parameter "${field.name}" is not nullable, whereas the corresponding class field is nullable. This use case is not supported.',
          element: classElement,
        );
      }
    }
  }

  bool _shouldGenerateCopyWithNull(
    bool copyWithNull,
    AnnotatedCopyWithSuper? superInfo,
    List<ConstructorParameterInfo> fields,
  ) {
    if (copyWithNull) return true;
    return superInfo?.copyWithNull == true &&
        fields.any((f) => f.nullable && !f.fieldAnnotation.immutable);
  }
}
